#!/bin/bash
#kubectl create ns snyk-monitor
kubectl create secret generic snyk-monitor -n snyk-monitor --from-literal=dockercfg.json={} --from-literal=integrationId=$TF_VAR_snyk_orgid

