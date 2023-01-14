/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
 * Optimisation stage that moves Yul variables from stack to memory.
 */

#pragma once

#include <libyul/optimiser/ASTWalker.h>
#include <libyul/optimiser/OptimiserStep.h>
#include <libsolutil/Common.h>

namespace solidity::yul
{

/**
 * Optimisation stage that moves Yul variables from stack to memory.
 * It takes a map from functions names and variable names to memory offsets.
 * It then transforms the AST as follows (after running ForLoopConditionIntoBody and ExpressionSplitter):
 *
 * In variable declarations, variables to be moved are replaced by fresh variables and then moved to memory:
 *   If b and d are in the map, replace
 *     let a, b, c, d := f()
 *   by
 *     let _1, _2, _3, _4 := f()
 *     mstore(<memory offset for d>, _4)
 *     mstore(<memory offset for b>, _2)
 *     let c := _3
 *     let a := _1
 *
 * Assignments are split up similarly to multi-variable declarations:
 *   If b and d are in the map, replace
 *     a, b, c, d := f()
 *   by
 *     let _1, _2, _3, _4 := f()
 *     mstore(<memory offset for d>, _4)
 *     mstore(<memory offset for b>, _2)
 *     c := _3
 *     a := _1
 *
 * After that, the ExpressionJoiner and ForLoopConditionOutOfBody transformations are run to reverse the preprocessing
 * and then all references to a variable ``a`` in the map are replaced by ``mload(<memory offset for a>)``.
 *
 * If a visited function has arguments or return parameters that are contained in the map,
 * TODO: document exactly what happens.
 *
 * Prerequisite: Disambiguator, ForLoopInitRewriter, FunctionHoister.
 */
class StackToMemoryMover
{
public:
	/**
	 * Runs the stack to memory mover.
	 * @param _reservedMemory Is the amount of previously reserved memory,
	 *                        i.e. the lowest memory offset to which variables can be moved.
	 * @param _memorySlots A map from variables to a slot in memory. Based on the slot a unique offset in the memory range
	 *                     between _reservedMemory and _reservedMemory + 32 * _numRequiredSlots is calculated for each
	 *                     variable.
	 * @param _numRequiredSlots The number of slots required in total. The maximum value that may occur in @a _memorySlots.
	 */
	static void run(
		OptimiserStepContext& _context,
		u256 _reservedMemory,
		std::map<YulString, uint64_t> const& _memorySlots,
		uint64_t _numRequiredSlots,
		Block& _block
	);
private:
	class VariableMemoryOffsetTracker
	{
	public:
		VariableMemoryOffsetTracker(
			u256 _reservedMemory,
			std::map<YulString, uint64_t> const& _memorySlots,
			uint64_t _numRequiredSlots
		): m_reservedMemory(_reservedMemory), m_memorySlots(_memorySlots), m_numRequiredSlots(_numRequiredSlots)
		{}

		/// @returns a YulString containing the memory offset to be assigned to @a _variable as number literal
		/// or std::nullopt if the variable should not be moved.
		std::optional<YulString> operator()(YulString _variable) const;
	private:
		u256 m_reservedMemory;
		std::map<YulString, uint64_t> const& m_memorySlots;
		uint64_t m_numRequiredSlots = 0;
	};
	class VariableDeclarationAndAssignmentMover: ASTModifier
	{
	public:
		VariableDeclarationAndAssignmentMover(
			OptimiserStepContext& _context,
			VariableMemoryOffsetTracker const& _memoryOffsetTracker
		): m_context(_context), m_memoryOffsetTracker(_memoryOffsetTracker)
		{
		}
		using ASTModifier::operator();
		void operator()(Block& _block) override;
	private:
		OptimiserStepContext& m_context;
		VariableMemoryOffsetTracker const& m_memoryOffsetTracker;
	};
	class IdentifierMover: ASTModifier
	{
	public:
		IdentifierMover(
			OptimiserStepContext& _context,
			VariableMemoryOffsetTracker const& _memoryOffsetTracker
		): m_context(_context), m_memoryOffsetTracker(_memoryOffsetTracker)
		{
		}
		using ASTModifier::operator();
		void visit(Expression& _expression) override;
	private:
		OptimiserStepContext& m_context;
		VariableMemoryOffsetTracker const& m_memoryOffsetTracker;
	};
	class FunctionDefinitionRewriter: ASTModifier
	{
	public:
		FunctionDefinitionRewriter(
			OptimiserStepContext& _context,
			VariableMemoryOffsetTracker const& _memoryOffsetTracker
		): m_context(_context), m_memoryOffsetTracker(_memoryOffsetTracker)
		{
		}
		using ASTModifier::operator();
		void operator()(FunctionDefinition& _functionDefinition) override;
	private:
		OptimiserStepContext& m_context;
		VariableMemoryOffsetTracker const& m_memoryOffsetTracker;
	};
	class FunctionCallRewriter: ASTModifier
	{
	public:
		FunctionCallRewriter(
			OptimiserStepContext& _context,
			VariableMemoryOffsetTracker const& _memoryOffsetTracker,
			std::map<YulString, FunctionDefinition const*> const& _functionDefinitions
		);
		using ASTModifier::operator();
		using ASTModifier::visit;
		void operator()(FunctionCall& _functionCall) override;
		void operator()(Block& _block) override;
	private:
		OptimiserStepContext& m_context;
		VariableMemoryOffsetTracker const& m_memoryOffsetTracker;
		struct FunctionArguments
		{
			std::vector<YulString> parameters;
			std::vector<YulString> returnVariables;
		};
		std::map<YulString, FunctionArguments> m_functionArguments;
		std::vector<Statement> m_statementsToPrefix;
		std::vector<std::optional<YulString>> m_slotsForCurrentReturns;
	};
};

}