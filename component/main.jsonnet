// main template for prometheus-pushgateway
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.prometheus_pushgateway;

{
    '02_alertrule_pushgateway_job' : {
        "apiVersion": "monitoring.coreos.com/v1",
        "kind": "PrometheusRule",
        "metadata": {
            "labels": params.prometheus_rule_labels + {
                "role": "alert-rules"
            },
            "name": "prometheus-pushgateway-rules",
            "namespace": params.prometheus_rule_namespace,
        },
        "spec": {
            "groups": [
                {
                    "name": "prometheus-pushgateway.rules",
                    "rules": [
                        {
                            "alert": "PushgatewayDown",
                            "annotations": {
                                "message": 'Platform pushgateway has disappeared from Prometheus target discovery.',
                                "runbook_url": "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletdown"
                            },
                            "expr": "absent(up{job=\"platform-prometheus-pushgateway\"} == 1)\n",
                            "for": "5m",
                            "labels": {
                                "severity": "warning"
                            }
                        }
                    ]
                }
            ]
        }
    },
}
