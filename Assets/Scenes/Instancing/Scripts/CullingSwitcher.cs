using GPUInstancedGrass.Common;
using UnityEngine;
using UnityEngine.UI;

namespace GPUInstancedGrass {
	public class CullingSwitcher : MonoBehaviour {
		private Toggle _toggle;
		private void Awake() {
			_toggle = GetComponent<Toggle>();
			_toggle.isOn = GrassField.PerformCulling;
			_toggle.onValueChanged.AddListener(OnToggleChanged);
		}

		private void OnToggleChanged(bool value) {
			_toggle.isOn = value;
			GrassField.PerformCulling = value;
		}
	}
}