import math
from typing import List
from calculator_token import Token
from operators import OPERATORS, FUNCTIONS

class Evaluator:
    @staticmethod
    def evaluate_command(command: str, args: List[str], evaluate_expression) -> float:
        if command not in FUNCTIONS:
            raise ValueError(f"Unknown command: {command}")
            
        # Recursively evaluate arguments
        evaluated_args = [evaluate_expression(arg) for arg in args]
        
        try:
            return FUNCTIONS[command]['func'](*evaluated_args)
        except TypeError:
            raise ValueError(f"Invalid number of arguments for {command}")
        except ValueError as e:
            raise ValueError(f"Error in command {command}: {str(e)}")

    @staticmethod
    def shunting_yard(tokens: List[Token]) -> List[Token]:
        output_queue: List[Token] = []
        operator_stack: List[Token] = []
        
        for token in tokens:
            if token.type == 'number':
                output_queue.append(token)
            elif token.type == 'command':
                operator_stack.append(token)
            elif token.type == 'operator':
                if token.value == '(':
                    operator_stack.append(token)
                elif token.value == ')':
                    while operator_stack and operator_stack[-1].value != '(':
                        output_queue.append(operator_stack.pop())
                    if not operator_stack:
                        raise ValueError("Mismatched parentheses")
                    operator_stack.pop()  # Remove '('
                    if operator_stack and operator_stack[-1].type == 'command':
                        output_queue.append(operator_stack.pop())
                else:
                    while (operator_stack and
                           operator_stack[-1].value != '(' and
                           operator_stack[-1].type in ('operator', 'function') and
                           ((OPERATORS[token.value]['associativity'] == 'left' and
                             OPERATORS[token.value]['precedence'] <= OPERATORS[operator_stack[-1].value]['precedence']) or
                            (OPERATORS[token.value]['associativity'] == 'right' and
                             OPERATORS[token.value]['precedence'] < OPERATORS[operator_stack[-1].value]['precedence']))):
                        output_queue.append(operator_stack.pop())
                    operator_stack.append(token)
        
        while operator_stack:
            if operator_stack[-1].value == '(':
                raise ValueError("Mismatched parentheses")
            output_queue.append(operator_stack.pop())
        
        return output_queue

    @staticmethod
    def evaluate_rpn(rpn_tokens: List[Token], evaluate_command) -> float:
        stack: List[float] = []
        
        for token in rpn_tokens:
            if token.type == 'number':
                stack.append(float(token.value))
            elif token.type == 'command':
                result = evaluate_command(token.value, token.args)
                stack.append(result)
            elif token.type == 'operator':
                if len(stack) < 2:
                    raise ValueError(f"Not enough operands for {token.value}")
                b = stack.pop()
                a = stack.pop()
                
                if token.value == '+':
                    stack.append(a + b)
                elif token.value == '-':
                    stack.append(a - b)
                elif token.value == '*':
                    stack.append(a * b)
                elif token.value == '/':
                    if b == 0:
                        raise ValueError("Division by zero")
                    stack.append(a / b)
                elif token.value == '^':
                    stack.append(math.pow(a, b))
        
        if len(stack) != 1:
            raise ValueError("Invalid expression")
        
        return stack[0]
