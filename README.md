# terraform-aws-eks-sentry-helm
Terraform module to create the sentry infrastructure using the helm chart.

## Database (Preferrably AWS RDS Posgres)
The helm chart doesn't create any database server and expects it be to be setup and reachable with a database named `sentry` created and accessiable via the db credentials setup in AWS secrets manager and the secret ARN passed into this module.

## Okta Integration

Okta SSO SAML setup instructions can be found [here](https://docs.sentry.io/product/accounts/sso/okta-sso/).


## Slack Integration
Slack integration steps can be found [here](https://docs.sentry.io/product/integrations/notification-incidents/slack/).

## JIRA Integration

JIRA integration steps can be found [here](https://docs.sentry.io/product/integrations/project-mgmt/jira/#jira-server).
