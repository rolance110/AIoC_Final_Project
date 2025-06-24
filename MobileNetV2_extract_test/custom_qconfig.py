from enum import Enum
import math

import torch
import torch.ao.quantization as tq


class PowerOfTwoObserver(tq.MinMaxObserver):
    """
    Observer module for power-of-two quantization (dyadic quantization with b = 1).
    """

    def scale_approximate(self, scale: float, max_shift_amount=8) -> float:
        #########Implement your code here##########
        # Handle edge cases
        if not math.isfinite(scale) or scale <= 0:
            return 1.0

        try:
            log2_scale = math.log2(scale)

            # Constrain log2_scale to prevent overflow
            log2_scale = max(min(log2_scale, max_shift_amount), -max_shift_amount)

            # Round to nearest power of two within constraints
            candidate = round(log2_scale)

            # Convert back to scale
            approx_scale = 2 ** candidate

            return approx_scale

        except (OverflowError, ValueError):
            # Fallback mechanism
            return 1.0
        ##########################################

    def calculate_qparams(self):
        """Calculates the quantization parameters with scale as power of two."""
        min_val, max_val = self.min_val.item(), self.max_val.item()

        """ Calculate zero_point as in the base class """
        # Find the absolute maximum to determine the range symmetrically
        abs_max = max(abs(min_val), abs(max_val))

        # Calculate the initial scale based on the full range
        scale = abs_max / (2 ** (self.dtype.itemsize * 8 - 1) - 1)

        # Determine zero point based on dtype
        #  0~255 : 128
        # -128~127 : 0
        if self.dtype == torch.qint8:
            zero_point = 0
        elif self.dtype == torch.quint8:
            zero_point = 128
        else:
            zero_point = 0  # Default fallback

        scale = self.scale_approximate(scale)
        scale = torch.tensor(scale, dtype=torch.float32)
        zero_point = torch.tensor(zero_point, dtype=torch.int64)
        return scale, zero_point

    def extra_repr(self):
        return f"min_val={self.min_val}, max_val={self.max_val}, scale=PowerOfTwo"


class CustomQConfig(Enum):
    POWER2 = tq.QConfig(
        activation=PowerOfTwoObserver.with_args(
            dtype=torch.quint8, qscheme=torch.per_tensor_symmetric
        ),
        weight=PowerOfTwoObserver.with_args(
            dtype=torch.qint8, qscheme=torch.per_tensor_symmetric
        ),
    )
    DEFAULT = None