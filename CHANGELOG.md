## ggscout-0.2.1 (2025-02-18)

### Feat

- **chart**: update examples
- **chart**: use secrets instead of configMap for Scout configuration

### Docs

- provides generated Scout documentation as GitHub pages

## ggscout-0.2.0 (2025-02-10)

### Feat

- **chart,cj**: define ttlSecondsAfterFinished and backoffLimit for jobs
- **cr**: use Release.Namespace and use proper helper for saName
- **image**: rework image path and imagepullsecrets to work with global values from GIM
- **psp**: add proper securityContext to jobs on enforced env. Default conf works with chainguard
- **nhi-explorer**: review doc and helm tests

### Fix

- **json-schema**: Set jsonschema version to 4.x
- **tests**: Fix tests after chart changes
- mise precommit install
- **cronjob**: Fix cronjob naming
- **chart**: pass namespace as a value on clusterrolebinding helm template
