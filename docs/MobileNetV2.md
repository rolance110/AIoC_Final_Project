Op(layer_id, layer_type, input_height, input_width, input_channel, output_height, output_width, output_channel, kH, kW, pad(T,B,L,R), bias, relu, skip, stride, expansion_factor, batch_norm, activation)
Op(1, FusedConv2D, 224, 224, 3, 112, 112, 32, 3, 3, (1,1,1,1), False, True, False, 2, None, True, ReLU6)
Op(2, FusedPointwiseConv2D, 112, 112, 32, 112, 112, 32, 1, 1, (0,0,0,0), False, True, False, 1, 1, False, ReLU6)
Op(3, FusedDepthwiseConv2D, 112, 112, 32, 112, 112, 32, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(4, PointwiseConv2D, 112, 112, 32, 112, 112, 16, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(5, FusedPointwiseConv2D, 112, 112, 16, 112, 112, 96, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(6, FusedDepthwiseConv2D, 112, 112, 96, 56, 56, 96, 3, 3, (1,1,1,1), False, True, False, 2, None, True, ReLU6)
Op(7, PointwiseConv2D, 56, 56, 96, 56, 56, 24, 1, 1, (0,0,0,0), False, False, False, 1, None, True, Linear)
Op(8, FusedPointwiseConv2D, 56, 56, 24, 56, 56, 144, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(9, FusedDepthwiseConv2D, 56, 56, 144, 56, 56, 144, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(10, PointwiseConv2D, 56, 56, 144, 56, 56, 24, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(11, FusedPointwiseConv2D, 56, 56, 24, 56, 56, 144, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(12, FusedDepthwiseConv2D, 56, 56, 144, 28, 28, 144, 3, 3, (1,1,1,1), False, True, False, 2, None, True, ReLU6)
Op(13, PointwiseConv2D, 28, 28, 144, 28, 28, 32, 1, 1, (0,0,0,0), False, False, False, 1, None, True, Linear)
Op(14, FusedPointwiseConv2D, 28, 28, 32, 28, 28, 192, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(15, FusedDepthwiseConv2D, 28, 28, 192, 28, 28, 192, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(16, PointwiseConv2D, 28, 28, 192, 28, 28, 32, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(17, FusedPointwiseConv2D, 28, 28, 32, 28, 28, 192, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(18, FusedDepthwiseConv2D, 28, 28, 192, 14, 14, 192, 3, 3, (1,1,1,1), False, True, False, 2, None, True, ReLU6)
Op(19, PointwiseConv2D, 14, 14, 192, 14, 14, 64, 1, 1, (0,0,0,0), False, False, False, 1, None, True, Linear)
Op(20, FusedPointwiseConv2D, 14, 14, 64, 14, 14, 384, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(21, FusedDepthwiseConv2D, 14, 14, 384, 14, 14, 384, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(22, PointwiseConv2D, 14, 14, 384, 14, 14, 64, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(23, FusedPointwiseConv2D, 14, 14, 64, 14, 14, 384, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(24, FusedDepthwiseConv2D, 14, 14, 384, 14, 14, 384, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(25, PointwiseConv2D, 14, 14, 384, 14, 14, 64, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(26, FusedPointwiseConv2D,  Lilliputian, 14, 14, 64, 14, 14, 384, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(27, FusedDepthwiseConv2D, 14, 14, 384, 14, 14, 384, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(28, PointwiseConv2D, 14, 14, 384, 14, 14, 64, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(29, FusedPointwiseConv2D, 14, 14, 64, 14, 14, 384, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(30, FusedDepthwiseConv2D, 14, 14, 384, 14, 14, 384, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(31, PointwiseConv2D, 14, 14, 384, 14, 14, 96, 1, 1, (0,0,0,0), False, False, False, 1, None, True, Linear)
Op(32, FusedPointwiseConv2D, 14, 14, 96, 14, 14, 576, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(33, FusedDepthwiseConv2D, 14, 14, 576, 14, 14, 576, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(34, PointwiseConv2D, 14, 14, 576, 14, 14, 96, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(35, FusedPointwiseConv2D, 14, 14, 96, 14, 14, 576, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(36, FusedDepthwiseConv2D, 14, 14, 576, 14, 14, 576, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(37, PointwiseConv2D, 14, 14, 576, 14, 14, 96, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(38, FusedPointwiseConv2D, 14, 14, 96, 14, 14, 576, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(39, FusedDepthwiseConv2D, 14, 14, 576, 7, 7, 576, 3, 3, (1,1,1,1), False, True, False, 2, None, True, ReLU6)
Op(40, PointwiseConv2D, 7, 7, 576, 7, 7, 160, 1, 1, (0,0,0,0), False, False, False, 1, None, True, Linear)
Op(41, FusedPointwiseConv2D, 7, 7, 160, 7, 7, 960, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(42, FusedDepthwiseConv2D, 7, 7, 960, 7, 7, 960, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(43, PointwiseConv2D, 7, 7, 960, 7, 7, 160, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(44, FusedPointwiseConv2D, 7, 7, 160, 7, 7, 960, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(45, FusedDepthwiseConv2D, 7, 7, 960, 7, 7, 960, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(46, PointwiseConv2D, 7, 7, 960, 7, 7, 160, 1, 1, (0,0,0,0), False, False, True, 1, None, True, Linear)
Op(47, FusedPointwiseConv2D, 7, 7, 160, 7, 7, 960, 1, 1, (0,0,0,0), False, True, False, 1, 6, False, ReLU6)
Op(48, FusedDepthwiseConv2D, 7, 7, 960, 7, 7, 960, 3, 3, (1,1,1,1), False, True, False, 1, None, True, ReLU6)
Op(49, PointwiseConv2D, 7, 7, 960, 7, 7, 320, 1, 1, (0,0,0,0), False, False, False, 1, None, True, Linear)
Op(50, FusedPointwiseConv2D, 7, 7, 320, 7, 7, 1280, 1, 1, (0,0,0,0), False, True, False, 1, None, True, ReLU6)
Op(51, GlobalAveragePooling2D, 7, 7, 1280, 1, 1, 1280, None, None, (0,0,0,0), False, False, False, None, None, False, None)
Op(52, Dense, 1, 1, 1280, None, None, 1000, None, None, (0,0,0,0), True, False, False, None, None, False, Softmax)