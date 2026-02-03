# Inception

*This project has been created as part of the 42 curriculum by vbonnard.*

## Description

Inception is a Docker-based infrastructure project that sets up a complete WordPress stack using containers. The project demonstrates advanced Docker and containerization concepts by orchestrating multiple services (Nginx, WordPress, and MariaDB) to create a fully functional website infrastructure.

### Project Goals

- **Understand containerization**: Learn how Docker isolates applications and their dependencies.
- **Multi-container orchestration**: Use Docker Compose to manage relationships between services.
- **Security implementation**: Configure SSL/TLS certificates, environment variables, and secrets management.
- **Persistent data storage**: Implement volume management to ensure data persists across container restarts.
- **Network isolation**: Create custom Docker networks for secure inter-container communication.

### Architecture Overview

The stack consists of three main services:

1. **Nginx** (Web Server)
   - Serves as the reverse proxy and web server
   - Handles SSL/TLS encryption with self-signed certificates
   - Routes requests to the PHP-FPM server

2. **WordPress** (PHP Application)
   - Runs PHP-FPM for dynamic content generation
   - Manages WordPress core files and plugins
   - Communicates with the MariaDB database

3. **MariaDB** (Database)
   - Provides the relational database backend
   - Stores all WordPress data (posts, users, configurations)
   - Ensures data persistence across container lifecycle

## Instructions

### Prerequisites

- Docker and Docker Compose installed on your system
- Bash shell
- Basic understanding of Docker concepts

### Installation & Compilation

1. **Clone the repository**:
   ```bash
   cd /Users/dev/Documents/Workspace/Doker/Inception
   ```

2. **Configure environment variables**:
   Edit the `.env` file in `srcs/` to set your database credentials, domain name, and admin credentials:
   ```
   DOMAIN_NAME=your-domain.com
   SITE_TITLE=Your Site Title
   SQL_DATABASE=wordpress
   SQL_USER=wp_user
   SQL_PASSWORD=secure_password
   SQL_ROOT_PASSWORD=root_password
   ```

3. **Create data directories** (required for bind mounts):
   ```bash
   mkdir -p /Users/dev/data/wordpress
   mkdir -p /Users/dev/data/mariadb
   chmod 777 /Users/dev/data/wordpress
   chmod 777 /Users/dev/data/mariadb
   ```

4. **Update your hosts file** (for local testing):
   ```bash
   sudo nano /etc/hosts
   # Add: 127.0.0.1 your-domain.com
   ```

### Building & Running

The project includes a Makefile for easy management:

```bash
# Start all services
make up

# Stop all services
make down

# View logs
make logs

# Clean all containers and volumes
make fclean

# Rebuild from scratch
make re
```

**Manual Docker Compose commands**:
```bash
cd srcs/
docker-compose up -d          # Start in detached mode
docker-compose logs -f        # Follow logs
docker-compose ps             # View running containers
docker-compose down           # Stop services
docker-compose down -v        # Stop and remove volumes
```

### Accessing the Website

- **WordPress site**: Navigate to `https://your-domain.com`
- **WordPress admin panel**: `https://your-domain.com/wp-admin`
- **Login credentials**: See `.env` file for `ADMIN_USER` and `ADMIN_PASSWORD`

## Docker Architecture & Design Choices

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|------------------|--------|
| **Overhead** | Full OS per instance (~GBs) | Lightweight container (~MBs) |
| **Boot time** | Minutes | Seconds |
| **Resource usage** | High (RAM, disk) | Low |
| **Use case** | Complete OS isolation | Process-level isolation |
| **This project** | ❌ Not suitable | ✅ Chosen for efficiency |

**Why Docker for Inception**: Containers provide enough isolation while minimizing resource consumption, making them ideal for development and CI/CD pipelines.

### Secrets vs Environment Variables

| Method | Pros | Cons | Used in Inception |
|--------|------|------|------------------|
| **Secrets** | More secure, encrypted at rest | Complex orchestration needed | ✅ Best practice (via .env + `env_file`) |
| **Environment Variables** | Simple, readable | Visible in processes, less secure | ⚠️ Used with caution |

**Design choice**: The project uses an `.env` file loaded via Docker Compose's `env_file` directive. This separates sensitive data from Docker image definitions. For production, consider using Docker secrets or HashiCorp Vault.

### Docker Network vs Host Network

| Network Type | Isolation | Performance | Security |
|--------------|-----------|-------------|----------|
| **Docker Network** | High (containers isolated) | Slight overhead | Better isolation |
| **Host Network** | None (shares host network) | Better performance | Containers exposed to host |

**Design choice**: The project uses a custom `inception` bridge network. This allows:
- Containers to communicate via internal DNS (e.g., `mariadb:3306`)
- External traffic only through Nginx on port 443
- No unnecessary port exposure

### Docker Volumes vs Bind Mounts

| Type | Use Case | Persistence | Portability |
|------|----------|-------------|------------|
| **Named Volumes** | Managed data | Managed by Docker | Better for production |
| **Bind Mounts** | Development, specific paths | Direct filesystem | More control |

**Design choice**: The project uses **bind mounts** to keep data in `/Users/dev/data/` for visibility and control. The configuration is:

```yaml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /Users/dev/data/wordpress
```

**Benefits**:
- Easy to backup data outside the project
- Direct access to files from the host
- Useful for development and debugging

## Resources

### Docker & Containerization
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Guide](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Nginx & Reverse Proxies
- [Nginx Beginners Guide](https://nginx.org/en/docs/beginners_guide.html)
- [SSL/TLS Configuration in Nginx](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)

### WordPress & PHP
- [WordPress.org Official Site](https://wordpress.org/)
- [WP-CLI Documentation](https://developer.wordpress.org/cli/commands/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)

### Database & MariaDB
- [MariaDB Official Documentation](https://mariadb.org/documentation/)
- [MySQL/MariaDB Basics](https://mariadb.com/kb/en/mariadb-basics/)

### Security
- [Let's Encrypt & HTTPS](https://letsencrypt.org/)
- [SSL/TLS Best Practices](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- [Environment Variable Security](https://12factor.net/config)

### AI Usage

AI assistance was used for:
1. **Script validation and debugging** - Reviewing shell scripts (setup.sh, entrypoint.sh) for correctness and best practices
2. **Docker configuration optimization** - Ensuring Dockerfile best practices and minimal image sizes
3. **Documentation structure** - Creating clear, comprehensive documentation following industry standards
4. **Troubleshooting guidance** - Explaining common Docker issues and solutions

AI did not generate the code itself; it provided guidance on structure, debugging, and best practices.