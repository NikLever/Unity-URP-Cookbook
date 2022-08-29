using GPUInstancedGrass.Common;
using TMPro;
using UnityEngine;

namespace GPUInstancedGrass {
	public class GrassCounterLabel : MonoBehaviour{
		private void Start() {
			GetComponent<TextMeshProUGUI>().text = $"Instance count: {GrassField.GrassDensity * GrassField.GrassDensity}";
		}
	}
}