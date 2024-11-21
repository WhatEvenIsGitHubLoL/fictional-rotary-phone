from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Optional
import logging
from logging.handlers import RotatingFileHandler
import os
from pathlib import Path
from calculator_engine import CalculatorEngine

# Setup logging
log_dir = Path("logs")
log_dir.mkdir(exist_ok=True)
log_file = log_dir / "calculator.log"

logging.basicConfig(
    handlers=[
        RotatingFileHandler(
            log_file,
            maxBytes=1024 * 1024,  # 1MB
            backupCount=5
        ),
        logging.StreamHandler()
    ],
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

class ExpressionRequest(BaseModel):
    """
    Model for calculation requests.
    
    Attributes:
        expression: The mathematical expression to evaluate
    """
    expression: str = Field(
        ...,
        description="The mathematical expression to evaluate",
        example="2 + 3 * (4 - 1) + log(100)"
    )

class CalculationResponse(BaseModel):
    """
    Model for calculation responses.
    
    Attributes:
        result: The result of the calculation
        formatted_expression: The formatted expression (optional)
    """
    result: float = Field(..., description="The result of the calculation")
    formatted_expression: Optional[str] = Field(None, description="The formatted expression")

app = FastAPI(
    title="Advanced Calculator API",
    description="A REST API for evaluating mathematical expressions with PEMDAS/BODMAS order",
    version="2.0.0"
)

# Configure CORS
origins = [
    "http://localhost:*",
    "http://127.0.0.1:*",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, this should be restricted
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize calculator engine
calculator = CalculatorEngine()

@app.post(
    "/calculate",
    response_model=CalculationResponse,
    responses={
        400: {"description": "Invalid expression or calculation error"},
        500: {"description": "Server error"},
    }
)
async def calculate(request: ExpressionRequest) -> CalculationResponse:
    """
    Endpoint to evaluate mathematical expressions.
    
    Supports:
    - Basic arithmetic operations (+, -, *, /)
    - Exponentiation (^)
    - Parentheses for grouping
    - Common logarithm (log)
    - Natural logarithm (ln)
    
    Args:
        request: The calculation request containing the mathematical expression
        
    Returns:
        CalculationResponse: The result of the calculation
        
    Raises:
        HTTPException: If the calculation fails or expression is invalid
    """
    try:
        logger.info(f"Received expression: {request.expression}")
        
        # Clean up the expression
        expression = request.expression.strip()
        
        # Evaluate the expression
        result = calculator.evaluate(expression)
        
        response = CalculationResponse(
            result=result,
            formatted_expression=expression
        )
        
        logger.info(f"Calculation successful: {response.dict()}")
        return response
    
    except ValueError as e:
        logger.error(f"Calculation error: {str(e)}")
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="An unexpected error occurred"
        )

@app.get("/")
async def root():
    """
    Root endpoint to verify API is running.
    """
    return {
        "message": "Advanced Calculator API is running",
        "version": "2.0.0",
        "documentation": "/docs",
        "supported_operations": [
            "Addition (+)",
            "Subtraction (-)",
            "Multiplication (*)",
            "Division (/)",
            "Exponentiation (^)",
            "Common logarithm (log)",
            "Natural logarithm (ln)",
            "Parentheses ( )"
        ]
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 5883))
    host = os.getenv("HOST", "0.0.0.0")
    
    uvicorn.run(
        app,
        host=host,
        port=port,
        log_level="info"
    )
