# Multi-Region Enterprise Multi-Cloud Infrastructure Base

A production-grade, highly secure AWS & Azure infrastructure baseline engineered for strict perimeter isolation, compliance-driven data segregation, and secure GitOps deployment validation.

## Target Architecture Blueprint

```mermaid
graph TD
    subgraph Public DMZ Layer [Public Subnets / DMZ]
        ALB[Application Load Balancer / Azure App Gateway]
    end

    subgraph Protected Application Layer [Private Compute Subnets]
        ASG[Auto Scaling Group / VM Scale Set]
    end

    subgraph Isolated Data Layer [Data Subnets - No Internet Routing]
        DB[(Encrypted PostgreSQL DB / Aurora Instance)]
    end

    %% Traffic Ingress Routing Flow
    Internet((Public Internet Traffic)) -->|HTTPS :443| ALB
    ALB -->|Forward Ingress Traffic :8080| ASG
    ASG -->|Secure Query TLS :5432| DB

    %% Component Visual Styles
    classDef public fill:#f9f,stroke:#333,stroke-width:2px;
    classDef private fill:#bbf,stroke:#333,stroke-width:2px;
    classDef isolated fill:#fbb,stroke:#333,stroke-width:2px;
    class ALB public;
    class ASG private;
    class DB isolated;
```

## Architectural Features
* **Multi-Cloud Parity:** Complete structural definitions mapped cleanly across both Amazon Web Services (AWS) and Microsoft Azure environments.
* **Perimeter Network Isolation:** Public entry points are strictly gated via Load Balancers. Compute nodes run inside private routing zones with no assigned public IP addresses.
* **Zero-Trust Secrets Handling:** Leverages OpenID Connect (OIDC) identity federations inside GitHub Action scripts, fully deprecating long-lived IAM access keys.
* **Compliant Data At-Rest Architecture:** Databases are cordoned into a third, isolated subnet tier completely devoid of default routing paths to the internet, enforcing strict encryption patterns.