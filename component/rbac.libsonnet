local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();

local metrics_role(name, namespace) =
  kube.Role(name) {
    metadata+: {
      namespace: namespace,
    },
    rules: [
      {
        apiGroups: [ '' ],
        resources: [ 'services', 'endpoints', 'pods' ],
        verbs: [ 'get', 'list', 'watch' ],
      },
    ],
  };

local ocp_metrics_rolebinding(name, namespace, metrics_role) =
  kube.RoleBinding(name) {
    metadata+: {
      namespace: namespace,
    },
    roleRef_:: metrics_role,
    subjects: [ {
      kind: 'ServiceAccount',
      name: 'prometheus-k8s',
      namespace: 'openshift-monitoring',
    } ],
  };

{
  metrics_role: metrics_role,
  ocp_metrics_rolebinding: ocp_metrics_rolebinding,
}
