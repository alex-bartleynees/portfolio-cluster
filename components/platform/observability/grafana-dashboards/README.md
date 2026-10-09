# Coffee Journal Grafana dashboards

Import each JSON file through **Dashboards → New → Import** and select the cluster's Prometheus, Loki, and Jaeger data sources when prompted.

- `coffee-platform-overview.json` covers HTTP golden signals, correlated logs, and recent traces for `coffee-journal-api`, `authgateway-bff`, and `payments-gateway`.
- `coffee-payments.json` covers Stripe, durable inbox, and transactional outbox business telemetry.

The PromQL uses the OpenTelemetry Collector Prometheus remote-write normalization currently configured by this cluster: dots become underscores, units are appended, and resource attribute `service.name` becomes label `service_name`.
