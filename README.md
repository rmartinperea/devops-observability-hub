# DevOps Observability Hub (Docker)

Este proyecto es un laboratorio personal para aprender cómo desplegar y monitorizar una infraestructura utilizando **Docker**.

El objetivo principal es entender cómo diferentes servicios pueden comunicarse entre sí, recoger métricas y visualizar el estado del sistema en tiempo real mediante Grafana.

---

# Tecnologías utilizadas

- Docker
- Docker Compose
- PostgreSQL
- pgAdmin
- Prometheus
- Grafana
- Node Exporter
- cAdvisor
- PostgreSQL Exporter
- Bash

---

# Arquitectura

```text
       Navegador
           │
   ┌───────┴────────┐
   │                │
   ▼                ▼
 Grafana         pgAdmin
   │                │
   ▼                ▼
 Prometheus    PostgreSQL
      │              ▲
      │              │
      ├──────────────┘
      │
      ├── Node Exporter
      ├── cAdvisor
      └── PostgreSQL Exporter

          Simulador CPU
```

Todos los servicios se comunican mediante una red privada creada por Docker Compose.

---

# ¿Qué hace este proyecto?

Con este laboratorio he aprendido a:

- Crear una infraestructura con Docker Compose.
- Desplegar una base de datos PostgreSQL.
- Administrar la base de datos mediante pgAdmin.
- Recoger métricas del sistema y de los contenedores.
- Visualizar esas métricas con Grafana.
- Configurar Prometheus como sistema de monitorización.
- Simular carga de CPU para comprobar que las métricas cambian en tiempo real.

---

# Estructura del proyecto

```text
.
├── docker-compose.yml
├── grafana/
├── prometheus/
├── scripts/
└── Dockerfile
```

---

# Componentes

## PostgreSQL

Base de datos utilizada durante el laboratorio.

---

## pgAdmin

Interfaz web para administrar PostgreSQL sin necesidad de utilizar únicamente la consola.

---

## Prometheus

Se encarga de recoger todas las métricas del sistema y almacenarlas.

---

## Grafana

Muestra la información recogida por Prometheus mediante dashboards.

---

## Node Exporter

Recoge información del sistema operativo:

- CPU
- Memoria
- Disco
- Red

---

## cAdvisor

Obtiene métricas de cada contenedor Docker:

- CPU
- RAM
- Uso de red
- Almacenamiento

---

## PostgreSQL Exporter

Expone métricas de PostgreSQL para que Prometheus pueda monitorizar la base de datos.

---

## Simulador CPU

Pequeño script en Bash ejecutado dentro de un contenedor que genera carga de CPU para comprobar que la monitorización funciona correctamente.

---

# Cómo ejecutar el proyecto

## Clonar el repositorio

```bash
git clone https://github.com/TU_USUARIO/devops-observability-hub.git
cd devops-observability-hub
```

## Levantar la infraestructura

```bash
docker compose up -d
```

---

# Acceso a los servicios

| Servicio | Dirección |
|----------|-----------|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| pgAdmin | http://localhost:8080 |

---

# Lo que he aprendido

Durante este proyecto he practicado conceptos como:

- Docker y Docker Compose.
- Redes entre contenedores.
- Persistencia de datos mediante volúmenes.
- Monitorización de infraestructura.
- Exporters de Prometheus.
- Dashboards en Grafana.
- Consultas básicas en PromQL.
- Organización de servicios mediante contenedores.

---

# Próximos pasos

Este laboratorio ha servido como base para el siguiente proyecto, donde toda la infraestructura se despliega sobre **Kubernetes (K3s)** utilizando:

- Deployments
- StatefulSets
- Services
- Ingress con Traefik
- ConfigMaps
- Secrets
- Persistent Volumes
- API REST desarrollada con Node.js y Express
