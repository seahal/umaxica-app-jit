# IntelliJ IDEA + Devcontainer

These steps show how to open the Umaxica devcontainer from IntelliJ IDEA (or JetBrains Gateway).

1. Install JetBrains Gateway 2024.1 or later and IntelliJ IDEA Ultimate locally. Ensure Docker Desktop/engine is running.
2. From Gateway choose **Dev Containers** → **Add Dev Container**. Point it at this repo's `.devcontainer/devcontainer.json`.
3. Gateway builds the Compose environment (all services defined in `.devcontainer/compose.yml`). The first build can take several minutes.
4. When prompted, pick IntelliJ IDEA as the backend and keep the recommended plugins. The Ruby plugin listed in the devcontainer configuration will be installed automatically.
5. Once the IDE connects, the container is left idle (the Rails server is not started automatically). Run `bin/dev` from the IDE terminal when you want to boot the app stack.
6. Database migrations and seeds run during container startup. If you need to re-run them manually you can call `bin/rails db:prepare`.

If Gateway reports permission errors, rebuild the container so it picks up your local UID/GID; those values are forwarded into the image during the build stage.
