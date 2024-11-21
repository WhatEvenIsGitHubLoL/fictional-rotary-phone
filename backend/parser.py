import re
from typing import List, Tuple
from calculator_token import Token
from operators import FUNCTIONS

class Parser:
    @staticmethod
    def parse_latex_command(expression: str, start: int) -> Tuple[Token, int]:
        """Parse a LaTeX-like command starting at the given position."""
        command_match = re.match(r'\\([a-zA-Z]+)', expression[start:])
        if not command_match:
            raise ValueError(f"Invalid command at position {start}")
        
        command = command_match.group(1)
        pos = start + len(command_match.group(0))
        
        if pos >= len(expression) or expression[pos] != '{':
            raise ValueError(f"Expected '{{' after command {command}")
        
        # Parse arguments
        args = []
        current_arg = ""
        nesting_level = 0
        pos += 1  # Skip opening brace
        
        while pos < len(expression):
            char = expression[pos]
            
            if char == '{':
                nesting_level += 1
                current_arg += char
            elif char == '}':
                if nesting_level == 0:
                    if current_arg:
                        args.append(current_arg.strip())
                    break
                nesting_level -= 1
                current_arg += char
            elif char == ',' and nesting_level == 0:
                args.append(current_arg.strip())
                current_arg = ""
            else:
                current_arg += char
            pos += 1
        
        if pos >= len(expression):
            raise ValueError(f"Unclosed command {command}")
            
        # For commands that need a second argument
        if command in FUNCTIONS and FUNCTIONS[command]['args'] == 2:
            if pos + 1 >= len(expression) or expression[pos + 1] != '{':
                raise ValueError(f"Expected second argument for {command}")
            
            pos += 2  # Skip } and next {
            second_arg = ""
            nesting_level = 0
            
            while pos < len(expression):
                char = expression[pos]
                
                if char == '{':
                    nesting_level += 1
                    second_arg += char
                elif char == '}':
                    if nesting_level == 0:
                        if second_arg:
                            args.append(second_arg.strip())
                        break
                    nesting_level -= 1
                    second_arg += char
                else:
                    second_arg += char
                pos += 1
            
            if pos >= len(expression):
                raise ValueError(f"Unclosed second argument for {command}")
            
        return Token('command', command, args), pos + 1

    @staticmethod
    def tokenize(expression: str) -> List[Token]:
        tokens = []
        pos = 0
        last_token_type = None
        
        while pos < len(expression):
            char = expression[pos]
            
            # Skip whitespace
            if char.isspace():
                pos += 1
                continue
                
            # Handle LaTeX-like commands
            if char == '\\':
                # Insert multiplication operator if previous token was a number
                if last_token_type == 'number':
                    tokens.append(Token('operator', '*'))
                
                token, new_pos = Parser.parse_latex_command(expression, pos)
                tokens.append(token)
                pos = new_pos
                last_token_type = 'command'
                continue
            
            # Handle numbers
            number_match = re.match(r'-?\d*\.?\d+', expression[pos:])
            if number_match:
                value = number_match.group(0)
                # Insert multiplication operator if previous token was a command
                if last_token_type == 'command':
                    tokens.append(Token('operator', '*'))
                tokens.append(Token('number', value))
                pos += len(value)
                last_token_type = 'number'
                continue
            
            # Handle operators
            if char in '+-*/^()':
                tokens.append(Token('operator', char))
                pos += 1
                last_token_type = 'operator'
                continue
                
            raise ValueError(f"Invalid character at position {pos}: {char}")
        
        return tokens
