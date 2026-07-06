#  DevOps Observability Hub: Laboratorio de Monitoreo & Hardening

Este es un laboratorio local de **Infraestructura como Código (IaC)** y **Observabilidad**. Está diseñado para simular cómo funciona el monitoreo de servidores en el mundo real, manejando bases de datos relacionales, telemetría automática y, lo más importante, aplicando capas de seguridad para proteger el entorno contra accesos no autorizados.

---

##  Arquitectura del Sistema

El proyecto levanta un ecosistema de **7 microservicios** totalmente interconectados a través de una red privada virtual de Docker (`red-infraestructura`). 

Para proteger los datos sensibles, **he aislado la red por dentro**, lo que significa que los servicios hablan entre sí en secreto y el único que da la cara al exterior es Grafana.

```text
       [ Navegador Web ]
               │  (Puerto 3000 protegido / Grafana)
               ▼
      ┌────────────────────────────────────────────────────────┐
      │                   RED DE DOCKER PRIVADA                │
      │                                                        │
      │   ┌───────────────┐        ┌───────────────────────┐   │
      │   │    Grafana    │◄───────┤ Prometheus (Métricas) │   │
      │   └───────────────┘        └───────────┬───────────┘   │
      │                                        │               │
      │         ┌──────────────────────────────┼───────────┐   │
      │         ▼                              ▼           ▼   │
      │  ┌───────────────┐              ┌─────────────┐ ┌─────────────┐
      │  │  PostgreSQL   │              │  cAdvisor   │ │Node Exporter│
      │  │ (Transacciones│              │(Contenedores)││  (Host/Red) │
      │  └──────▲────────┘              └─────────────┘ └─────────────┘
      │         │                                              │
      │  ┌──────┴────────┐                                     │
      │  │ Simulador CPU │ (Inyección de Picos)                │
      │  └───────────-───┘                                     │
      └────────────────────────────────────────────────────────┘
```

### Componentes de la Infraestructura

1. **Capa de Visualización (Grafana):** Nuestro panel de control centralizado. Es el único punto expuesto hacia tu máquina y se conecta con un bot de **Slack (ChatOps)** para avisar al equipo al instante si algo falla.
2. **Motor de Telemetría (Prometheus):** La base de datos de series temporales (TSDB) que traga e indexa todas las métricas de rendimiento.
3. **Capa de Datos (PostgreSQL + pgAdmin):** Almacenamiento persistente que simula la base de datos de negocio de una empresa real.
4. **Simulador Autónomo de Estrés (Bash + Dockerfile):** Un microservicio programado por nosotros que corre de fondo inyectando picos de CPU al 99% y caídas de servicio (`DOWN`) para poner a prueba las alertas.
5. **Agentes de Recolección (cAdvisor + Node Exporter):** Los ojos del sistema. `cAdvisor` vigila el consumo interno de cada contenedor y `Node Exporter` mide el tráfico de red general.

---

##  Buenas Prácticas de Seguridad Implementadas (Hardening)

Un error típico es dejar todos los puertos abiertos. En este laboratorio he blindado la seguridad con estándares corporativos:

* **Principio de Menor Privilegio (Bloqueo de Puertos):** Borramos las directivas `ports` hacia el exterior en PostgreSQL, Prometheus, cAdvisor y Node Exporter. Todo el tráfico viaja aislado por la red de Docker.
* **Protección contra Llenado de Disco (Anti-DoS):** Limitamos por comandos la retención de Prometheus (`--storage.tsdb.retention.size=5GB` y `7d`). Así evitamos que un ataque o un bug llene el disco duro del servidor y tumbe el sistema [^1].

---

##  Métricas Clave Diseñadas (PromQL & SQL)

Para que los paneles de Grafana he diseñado las siguientes gráficas interactivas:

* **Velocidad de Escritura en Disco por Contenedores (MB/s):**
Como los entornos virtuales a veces bloquean las métricas de disco tradicionales, he usado esta fórmula inteligente que aprovecha cAdvisor para medir los Megabytes reales que escriben tus contenedores por segundo:
  ```promql
  sum(rate(container_fs_writes_bytes_total[5m])) / 1024 / 1024
  ```
* **Estado de Salud de los Nodos (Up/Down):**
  Consulta para comprobar en tiempo real qué contenedores están vivos (`1`) y cuáles han caído (`0`):
  ```promql
  up
  ```

---

##  Capacidades Demostradas en este Lab

* **Infraestructura como Código (IaC):** Despliegue limpio y repetible mediante Docker Compose, usando volúmenes persistentes para no perder datos al apagar.
* **DNS Interno de Docker:** Conexión segura entre servicios usando sus nombres de contenedor en lugar de IPs estáticas que cambian todo el tiempo.
* **Gestión de Incidentes:** Simulación real de picos de carga (Thresholds) y caídas de servidores para configurar alertas visuales inteligentes en color.

---

##  Despliegue Rápido (Quickstart)

### Requisitos Previos
* Docker y Docker Compose instalados.
* Funciona perfectamente en entornos Linux o **WSL2 (Windows Subsystem for Linux)** [^1].

### Instrucciones
1. Clona este repositorio en tu máquina:
   ```bash
   git clone https://github.com
   cd devops-observability-hub
   ```
2. Compila el simulador y levanta toda la infraestructura blindada en segundo plano con un solo comando:
   ```bash
   docker compose up -d --remove-orphans
   ```
3. Entra a tu navegador y disfruta del monitoreo:
   * **Grafana (Paneles):** `http://localhost:3000` (Usuario/Contraseña por defecto: `admin` / `admin`)
   * *(Nota: Intentar entrar a Prometheus en el puerto 9090 o cAdvisor en el 8080 dará conexión rechazada debido al bloqueo de seguridad implementado).*
  
  
   ##  Solución de Problemas Frecuentes (Troubleshooting)

* **¿Por qué las métricas de disco de Node Exporter dan "No Data" en WSL/Windows?**
  WSL2 aísla el sistema de archivos mediante hipervisores, impidiendo que los contenedores accedan a las métricas del host directamente. En este laboratorio mitigamos este comportamiento sustituyendo la métrica tradicional por telemetría nativa de contenedores mediante **cAdvisor** (`container_fs_writes_bytes_total`).
* **Grafana da error al conectar con Prometheus:**
  Asegúrate de que la URL en el Data Source de Grafana sea `http://devops_prometheus:9090`. No uses `localhost`, ya que dentro de la red interna de Docker, `localhost` apuntaría a la propia Grafana.


---
