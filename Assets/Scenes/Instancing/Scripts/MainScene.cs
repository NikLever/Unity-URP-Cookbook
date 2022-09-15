using GPUInstancedGrass.Common;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace GPUInstancedGrass {
	public class MainScene : MonoBehaviour {
		[SerializeField]
		private TextMeshProUGUI _counter;

		private void Awake() {
            Application.targetFrameRate = 60;
			UpdateCounter();
		}
		
		public void ChangeGrassDensity(int value) {
			GrassField.GrassDensity += value;
			UpdateCounter();
		}

		public void StartScene(int index) {
			SceneManager.LoadScene(index);
		}
		
		private void UpdateCounter() {
			_counter.text = (GrassField.GrassDensity * GrassField.GrassDensity).ToString();
		}
	}
}