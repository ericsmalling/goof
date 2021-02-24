#!/bin/bash
helm repo add snyk-charts https://snyk.github.io/kubernetes-monitor/

kubectl create ns snyk-monitor

kubectl create secret generic snyk-monitor -n snyk-monitor --from-literal=dockercfg.json={} --from-literal=integrationId=$TF_VAR_snyk_orgid

helm upgrade --install snyk-monitor snyk-charts/snyk-monitor --namespace snyk-monitor --set clusterName="EKS monitored by Snyk"
