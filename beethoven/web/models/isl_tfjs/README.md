Place your TensorFlow.js model files here.

Expected files:
- model.json
- group1-shard1ofN.bin (one or more shards)

The app loads the model from:
- models/isl_tfjs/model.json

You can generate these files from a SavedModel or Keras model using:

  tensorflowjs_converter \
    --input_format=tf_saved_model \
    --output_format=tfjs_graph_model \
    /path/to/saved_model \
    /path/to/this/folder
