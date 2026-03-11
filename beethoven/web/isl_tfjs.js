(function () {
  async function loadModel(modelUrl) {
    if (!window.tf) {
      throw new Error('TensorFlow.js not loaded');
    }
    await tf.ready();
    window.islTfjsModel = await tf.loadGraphModel(modelUrl);
    return true;
  }

  async function predict(input) {
    if (!window.islTfjsModel) {
      throw new Error('TFJS model not loaded');
    }
    const tensor = tf.tensor(input);
    const output = window.islTfjsModel.predict(tensor);
    const data = await output.data();
    tensor.dispose();
    output.dispose();
    return Array.from(data);
  }

  window.islTfjs = { loadModel, predict };
})();
