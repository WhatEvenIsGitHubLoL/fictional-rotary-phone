from backend.calculator_engine import CalculatorEngine

def test_calculator():
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

if __name__ == "__main__":
    test_calculator()
