from typing import List
from calculator_token import Token
from parser import Parser
from evaluator import Evaluator

class CalculatorEngine:
    def __init__(self):
        self.parser = Parser()
        self.evaluator = Evaluator()

    def evaluate_command(self, command: str, args: List[str]) -> float:
        return self.evaluator.evaluate_command(command, args, self.evaluate)

    def evaluate(self, expression: str) -> float:
        try:
            tokens = self.parser.tokenize(expression)
            rpn_tokens = self.evaluator.shunting_yard(tokens)
            return self.evaluator.evaluate_rpn(rpn_tokens, self.evaluate_command)
        except Exception as e:
            raise ValueError(f"Error evaluating expression: {str(e)}")

# Example usage and testing
if __name__ == "__main__":
    calc = CalculatorEngine()
    test_expressions = [
        r"3\sqrt{5} + \frac{9}{2}",  # 3√5 + 9/2
        r"\frac{1}{2} + \frac{3}{4}",  # 1/2 + 3/4
        r"2\sqrt{9} + \frac{5}{2}",  # 2√9 + 5/2
    ]
    
    for expr in test_expressions:
        try:
            result = calc.evaluate(expr)
            print(f"{expr} = {result}")
        except Exception as e:
            print(f"Error evaluating {expr}: {str(e)}")
