(function () {
  async function loadModel(modelUrl) {
    if (!window.tf) {
      throw new Error('TensorFlow.js not loaded');
    }

    console.info('[isl_tfjs][loadModel] start', { modelUrl });
    await tf.ready();

    const response = await fetch(modelUrl, { cache: 'no-cache' });
    if (!response.ok) {
      throw new Error(`Failed to fetch model.json: ${response.status} ${response.statusText}`);
    }

    const modelJson = await response.json();
    const modelFormat = modelJson.format || 'unknown';
    console.info('[isl_tfjs][loadModel] detected format', { modelFormat });

    try {
      if (modelFormat === 'layers-model') {
        window.islTfjsModel = await tf.loadLayersModel(modelUrl);
        console.info('[isl_tfjs][loadModel] loaded with loadLayersModel');
      } else {
        window.islTfjsModel = await tf.loadGraphModel(modelUrl);
        console.info('[isl_tfjs][loadModel] loaded with loadGraphModel');
      }
    } catch (primaryError) {
      console.error('[isl_tfjs][loadModel] primary loader failed', primaryError);

      // Fallback loader for mismatched format declarations.
      if (modelFormat === 'layers-model') {
        window.islTfjsModel = await tf.loadGraphModel(modelUrl);
        console.warn('[isl_tfjs][loadModel] fallback to loadGraphModel succeeded');
      } else {
        window.islTfjsModel = await tf.loadLayersModel(modelUrl);
        console.warn('[isl_tfjs][loadModel] fallback to loadLayersModel succeeded');
      }
    }

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
