import uvicorn
from .rest_api_server import *


def main():

    # Start REST API server
    uvicorn.run(
        "fortune.rest_api_server:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )

if __name__ == "__main__":
    main()