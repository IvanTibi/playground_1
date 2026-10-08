# Fortune REST API

A simple Fortune REST API implemented in Python using FastAPI and Uvicorn.

The project demonstrates:

* Python application development
* Automated testing with pytest
* Python package building
* Debian and SUSE Docker images
* Docker-based deployment
* Security scanning with Snyk
* GitHub Actions CI/CD
* Google Artifact Registry
* Google Cloud Run deployment
* GitHub OIDC authentication with Google Cloud Workload Identity Federation
* GitHub staging environment

---

# Project structure

```text
fortune/
├── .github/
│   └── workflows/
│       └── ci.yml
├── tests/
│   └── test_fortune.py
├── src/
│   └── fortune/
│       ├── __init__.py
│       ├── __main__.py
│       ├── fortune.py
│       └── rest_api_server.py
├── docker/
│   ├── Dockerfile.debian
│   └── Dockerfile.suse
├── dist/
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── pyproject.toml
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

The project uses Python 3.12.

---

# 2. Install the project in development mode

Install the package into the virtual environment:

```powershell
python -m pip install -e .
```

For development and testing:

```powershell
python -m pip install -e ".[dev]"
```

The `-e` option installs the project in editable mode, so changes to the source code are immediately available without rebuilding and reinstalling the package.

---

# 3. Build the Python wheel

Install the Python build tool:

```powershell
python -m pip install build
```

Build the package:

```powershell
python -m build
```

The build creates:

```text
dist/
├── fortune_technical_interwiew_task-0.0.1-py3-none-any.whl
└── fortune_technical_interwiew_task-0.0.1.tar.gz
```

The `.whl` file is the Python wheel and is used by the Docker build.

---

# 4. Run the application locally

Start the application:

```powershell
python -m fortune
```

The local API listens on:

```text
http://127.0.0.1:8000
```

Swagger/OpenAPI documentation:

```text
http://127.0.0.1:8000/docs
```

Example endpoint:

```text
GET http://127.0.0.1:8000/fortune
```

---

# 5. Run tests

The test suite uses pytest.

Run:

```powershell
pytest
```

The tests cover:

* Fortune creation
* Loading fortunes
* Unique IDs
* Retrieving a fortune by ID
* Invalid IDs
* Random fortune retrieval

Tests are also executed automatically by GitHub Actions.

---

# 6. Build the Debian Docker image

The Debian Dockerfile is:

```text
docker/Dockerfile.debian
```

Build the image from the project root:

```powershell
docker build -f docker/Dockerfile.debian -t fortune:0.0.1-debian .
```

Verify:

```powershell
docker images
```

---

# 7. Run the Debian Docker container

Run the container locally:

```powershell
docker run --rm -p 127.0.0.1:8000:8000 fortune:0.0.1-debian
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

# 8. Build the SUSE Docker image

The SUSE Dockerfile is:

```text
docker/Dockerfile.suse
```

Build:

```powershell
docker build -f docker/Dockerfile.suse -t fortune:0.0.1-suse .
```

The build must be executed from the project root so Docker can access the Python wheel in `dist/`.

---

# 9. Run the SUSE Docker container

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

---

# 10. Debian vs. SUSE

The application is identical in both images.

| Image                  | Base OS       | Package manager |
| ---------------------- | ------------- | --------------- |
| `fortune:0.0.1-debian` | Debian        | apt             |
| `fortune:0.0.1-suse`   | openSUSE Leap | zypper          |

The same Python wheel is installed in both images.

---

# 11. CI/CD Pipeline

The project uses GitHub Actions for CI/CD.

The workflow is located at:

```text
.github/workflows/ci.yml
```

The pipeline performs:

```text
GitHub
   |
   v
GitHub Actions
   |
   +---- pytest
   |
   +---- Python wheel build
   |
   +---- Docker build
   |
   +---- Snyk security scan
   |
   +---- Google Cloud authentication
   |
   +---- Push Docker image
   |       |
   |       v
   |   Artifact Registry
   |       |
   |       v
   |    Cloud Run
   |
   +---- Staging deployment
```

The pipeline runs automatically on pushes to the `main` branch and on pull requests targeting `main`.

---

# 12. CI testing

The test job:

1. Checks out the repository.
2. Installs Python 3.12.
3. Installs the project and development dependencies.
4. Runs pytest.

Example:

```yaml
- name: Run tests
  run: |
    pytest
```

A failed test prevents the following build/deployment stages from running.

---

# 13. Docker build

After successful tests, GitHub Actions builds the Docker image.

The image is tagged using the Git commit SHA:

```text
fortune:${{ github.sha }}
```

Using the Git SHA instead of `latest` makes the image immutable and allows a specific source revision to be identified and deployed.

---

# 14. Security scanning with Snyk

The Docker image is scanned using Snyk.

The pipeline uses the repository secret:

```text
SNYK_TOKEN
```

The token is stored in:

```text
GitHub
→ Settings
→ Secrets and variables
→ Actions
```

It is injected into the workflow using:

```yaml
env:
  SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

The secret is never committed to the repository.

The current scan reports vulnerabilities but does not block the pipeline:

```bash
snyk container test fortune:${{ github.sha }} \
  --file=docker/Dockerfile.debian \
  --severity-threshold=high || true
```

This allows security findings to be visible during the interview/demo while keeping the deployment pipeline operational.

In a production environment, the `|| true` behavior could be removed so that high-severity vulnerabilities block deployment.

---

# 15. Google Cloud deployment

The application is deployed to Google Cloud using:

* Google Artifact Registry
* Google Cloud Run
* Google Workload Identity Federation
* GitHub Actions OIDC

The GCP project used for the deployment is:

```text
project-f06f7e25-398a-4a3d-899
```

The Artifact Registry repository is:

```text
fortune
```

Region:

```text
europe-west1
```

---

# 16. Artifact Registry

Artifact Registry is used as the private Docker image registry.

The image is pushed to:

```text
europe-west1-docker.pkg.dev/project-f06f7e25-398a-4a3d-899/fortune/fortune
```

Images are tagged using the Git commit SHA:

```text
fortune:<git-sha>
```

This provides a direct relationship between:

```text
Git commit
    ↓
Docker image
    ↓
Cloud Run revision
```

---

# 17. GitHub → Google Cloud authentication

The pipeline does not use a long-lived Google Cloud service-account JSON key.

Instead, GitHub Actions uses:

```text
GitHub OIDC
      ↓
Workload Identity Federation
      ↓
GCP service account
```

This avoids storing long-lived GCP credentials in GitHub.

The Workload Identity Pool is:

```text
github-pool
```

The OIDC provider is:

```text
github
```

The provider is restricted to the repository:

```text
IvanTibi/playground_1
```

The GitHub Actions service account is:

```text
github-actions@project-f06f7e25-398a-4a3d-899.iam.gserviceaccount.com
```

The service account is granted the minimum roles required for the deployment:

* Artifact Registry Writer
* Cloud Run Admin
* Service Account User

---

# 18. Cloud Run

The application is deployed to Google Cloud Run.

Cloud Run service:

```text
fortune
```

Region:

```text
europe-west1
```

The deployed image is the same immutable image that was built and pushed by the CI pipeline:

```text
europe-west1-docker.pkg.dev/project-f06f7e25-398a-4a3d-899/fortune/fortune:${{ github.sha }}
```

The deployment uses:

```text
minimum instances: 0
maximum instances: 1
```

This allows the service to scale to zero when it is not being used and limits the resources used by the interview/demo environment.

The service is exposed through HTTPS.

---

# 19. Cloud Run port configuration

Cloud Run provides the container with the environment variable:

```text
PORT=8080
```

The application therefore reads the port from the environment:

```python
import os

port = int(os.environ.get("PORT", "8000"))
```

and starts Uvicorn using:

```python
uvicorn.run(
    app,
    host="0.0.0.0",
    port=port
)
```

This allows the same application to run locally on port `8000` while using port `8080` in Cloud Run.

The Docker image exposes:

```dockerfile
EXPOSE 8080
```

---

# 20. Staging environment

GitHub Actions uses a GitHub Environment named:

```text
staging
```

The deployment job is associated with this environment:

```yaml
environment:
  name: staging
```

This provides a separate logical environment for the deployed application and allows environment-specific protection rules and secrets to be added later.

---

# 21. Complete CI/CD flow

The complete deployment process is:

```text
Developer
   |
   | git push
   v
GitHub
   |
   v
GitHub Actions
   |
   +----------------+
   |                |
   v                v
pytest          Build wheel
                    |
                    v
                Docker build
                    |
                    v
                Snyk scan
                    |
                    v
          GitHub OIDC authentication
                    |
                    v
          Google Artifact Registry
                    |
                    v
              Google Cloud Run
                    |
                    v
             Fortune REST API
```

---

# 22. API testing

Once Cloud Run has deployed the service, Google Cloud provides an HTTPS URL similar to:

```text
https://fortune-xxxxxxxx-ew.a.run.app
```

Swagger/OpenAPI documentation is available at:

```text
https://fortune-xxxxxxxx-ew.a.run.app/docs
```

The random fortune endpoint is:

```text
GET /fortune
```

A specific fortune can be requested using:

```text
GET /fortune/{fortune_id}
```

For example:

```text
GET /fortune/10
```

---

# 23. Local vs. Cloud deployment

| Environment  | Port | Runtime          |
| ------------ | ---: | ---------------- |
| Local Python | 8000 | Python/Uvicorn   |
| Local Docker | 8000 | Docker           |
| Cloud Run    | 8080 | Docker/Cloud Run |

Cloud Run supplies the `PORT` environment variable and the application binds to that port.

---

# 24. Quick commands

Activate environment:

```powershell
.\.venv\Scripts\Activate.ps1
```

Run tests:

```powershell
pytest
```

Build wheel:

```powershell
python -m build
```

Build Debian image:

```powershell
docker build -f docker/Dockerfile.debian -t fortune:0.0.1-debian .
```

Run Debian image:

```powershell
docker run --rm -p 127.0.0.1:8000:8000 fortune:0.0.1-debian
```

Build SUSE image:

```powershell
docker build -f docker/Dockerfile.suse -t fortune:0.0.1-suse .
```

Run SUSE image:

```powershell
docker run --rm -p 127.0.0.1:8000:8000 fortune:0.0.1-suse
```

---

# 25. Security considerations

The project demonstrates several basic security practices:

* Secrets are stored using GitHub Actions Secrets.
* No GCP service-account JSON key is stored in GitHub.
* GitHub OIDC is used for cloud authentication.
* Workload Identity Federation restricts access to the intended GitHub repository.
* The deployment service account uses scoped IAM roles.
* Docker images are scanned with Snyk.
* Docker images use immutable Git SHA tags.
* Cloud Run scales to zero when unused.
* The staging environment is separated using a GitHub Environment.

For a production deployment, the Snyk scan could be configured as a blocking security gate and additional network, IAM and application-level controls could be added.

---

# 26. Interview demonstration

The recommended demonstration flow is:

1. Show the GitHub repository.
2. Show `.github/workflows/ci.yml`.
3. Make a small change and push it to GitHub.
4. Open **GitHub Actions**.
5. Show the test stage.
6. Show the Docker build.
7. Show the Snyk security scan.
8. Show authentication to GCP using OIDC.
9. Show the Docker image in Artifact Registry.
10. Show the Cloud Run deployment.
11. Open the Cloud Run HTTPS URL.
12. Open `/docs`.
13. Execute `GET /fortune`.
14. Show the returned JSON response.

This demonstrates the complete flow from source code to a running cloud service.
