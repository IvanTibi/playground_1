# Fortune REST API

A simple Fortune REST API implemented in Python using FastAPI and Uvicorn.

The project can be packaged as a Python wheel and then installed into a Docker image. Two Docker base-image options are provided:

* Debian-based: `python:3.12-slim`
* SUSE-based: `opensuse/leap:16.1`

## Project structure

```text
fortune/
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── pyproject.toml
├── dist/
│   ├── fortune_technical_interwiew_task-0.0.1-py3-none-any.whl
│   └── fortune_technical_interwiew_task-0.0.1.tar.gz
├── docker/
│   ├── Dockerfile.debian
│   └── Dockerfile.suse
└── src/
    └── fortune/
        ├── __init__.py
        ├── __main__.py
        ├── fortune.py
        └── rest_api_server.py
```

---

# 1. Create and activate the virtual environment

From the project root:

```powershell
python -m venv .venv
```

Activate it:

```powershell
.\.venv\Scripts\Activate.ps1
```

Verify Python:

```powershell
python --version
```

---

# 2. Install the project in development mode

Install the package into the virtual environment:

```powershell
python -m pip install -e .
```

The `-e` option installs the project in editable mode, so changes to the source code are immediately available without rebuilding and reinstalling the package.

---

# 3. Build the Python wheel

Install the Python build tool if it is not already installed:

```powershell
python -m pip install build
```

Build the package:

```powershell
python -m build
```

The build creates the `dist` directory:

```text
dist/
├── fortune_technical_interwiew_task-0.0.1-py3-none-any.whl
└── fortune_technical_interwiew_task-0.0.1.tar.gz
```

The `.whl` file is the Python wheel and is the artifact used by the Docker build.

The `.tar.gz` file is the source distribution (sdist).

---

# 4. Run the application locally

The application can be started directly from the virtual environment:

```powershell
python -m fortune
```

The API listens on:

```text
http://127.0.0.1:8000
```

Swagger/OpenAPI documentation is available at:

```text
http://127.0.0.1:8000/docs
```

Example endpoint:

```text
GET http://127.0.0.1:8000/fortune
```

---

# 5. Build the Debian Docker image

The Debian Dockerfile is:

```text
docker/Dockerfile.debian
```

Build the image from the project root:

```powershell
docker build -f docker/Dockerfile.debian -t fortune:0.0.1-debian .
```

The final `.` is important because the Docker build context must contain the `dist` directory.

Verify that the image exists:

```powershell
docker images
```

You should see an image similar to:

```text
fortune   0.0.1-debian
```

---

# 6. Run the Debian Docker container

Run the container and expose port 8000 only on the local machine:

```powershell
docker run --rm -p 127.0.0.1:8000:8000 fortune:0.0.1-debian
```

The API is now available at:

```text
http://127.0.0.1:8000/fortune
```

Swagger UI:

```text
http://127.0.0.1:8000/docs
```

Stop the container with:

```text
Ctrl+C
```

Because `--rm` is used, the container is automatically removed after it stops.

---

# 7. Build the SUSE Docker image

The SUSE Dockerfile is:

```text
docker/Dockerfile.suse
```

Build the image:

```powershell
docker build -f docker/Dockerfile.suse -t fortune:0.0.1-suse .
```

Again, the build must be executed from the project root so Docker can access:

```text
dist/fortune_technical_interwiew_task-0.0.1-py3-none-any.whl
```

---

# 8. Run the SUSE Docker container

Run the container:

```powershell
docker run --rm -p 127.0.0.1:8000:8000 fortune:0.0.1-suse
```

The API is available at:

```text
http://127.0.0.1:8000/fortune
```

Swagger UI:

```text
http://127.0.0.1:8000/docs
```

Stop the container with:

```text
Ctrl+C
```

---

# 9. Debian vs. SUSE

The application itself is identical in both images.

The difference is the base operating system:

| Image                  | Base OS       | Package manager |
| ---------------------- | ------------- | --------------- |
| `fortune:0.0.1-debian` | Debian        | `apt`           |
| `fortune:0.0.1-suse`   | openSUSE Leap | `zypper`        |

The Python wheel is the same for both images:

```text
fortune_technical_interwiew_task-0.0.1-py3-none-any.whl
```

The Docker image installs the wheel using `pip`.

The Python dependencies declared in `pyproject.toml` are installed automatically when the wheel is installed.

---

# 10. Complete build procedure

The complete workflow from source code to a running Docker container is:

```text
Python source code
       |
       v
python -m build
       |
       v
Python wheel
       |
       +----------------------+
       |                      |
       v                      v
Docker Debian             Docker SUSE
       |                      |
       v                      v
fortune:0.0.1-debian    fortune:0.0.1-suse
       |                      |
       +----------+-----------+
                  |
                  v
             Docker container
                  |
                  v
          FastAPI REST service
                  |
                  v
        http://127.0.0.1:8000
```

---

# 11. Quick commands

## Build wheel

```powershell
.\.venv\Scripts\Activate.ps1
python -m build
```

## Build Debian image

```powershell
docker build -f docker/Dockerfile.debian -t fortune:0.0.1-debian .
```

## Run Debian image

```powershell
docker run --rm -p 127.0.0.1:8000:8000 fortune:0.0.1-debian
```

## Build SUSE image

```powershell
docker build -f docker/Dockerfile.suse -t fortune:0.0.1-suse .
```

## Run SUSE image

```powershell
docker run --rm -p 127.0.0.1:8000:8000 fortune:0.0.1-suse
```

---

# 12. Testing the API

Once the container is running, open:

```text
http://127.0.0.1:8000/docs
```

The Swagger UI allows the available REST endpoints to be tested directly from the browser.

For example:

```text
GET /fortune
```

returns a random fortune.

A specific fortune can be requested using:

```text
GET /fortune/{fortune_id}
```

For example:

```text
GET /fortune/10
```

---

# 13. Docker port mapping

The Docker command:

```powershell
docker run --rm -p 127.0.0.1:8000:8000 fortune:0.0.1-debian
```

uses the following mapping:

```text
HOST                         CONTAINER
127.0.0.1:8000  ---------->  0.0.0.0:8000
```

The application inside the container listens on:

```text
0.0.0.0:8000
```

while Docker exposes it on:

```text
127.0.0.1:8000
```

This means the service is accessible from the local machine but is not published on the host's other network interfaces.

To bind the Docker port to all host interfaces instead:

```powershell
docker run --rm -p 0.0.0.0:8000:8000 fortune:0.0.1-debian
```

Use this only when access from other machines is actually required.
