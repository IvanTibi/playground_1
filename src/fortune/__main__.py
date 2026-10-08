import uvicorn
from .rest_api_server import *
import os

port = int(os.environ.get("PORT", "8000"))

def main():

    # Start REST API server
    uvicorn.run(
        "fortune.rest_api_server:app",
        host="0.0.0.0",
        port=port,
        reload=True,
    )

if __name__ == "__main__":
    main()