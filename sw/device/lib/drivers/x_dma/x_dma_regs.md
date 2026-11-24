## Summary

| Name                      | Offset   |   Length | Description      |
|:--------------------------|:---------|---------:|:-----------------|
| x_dma.[`STATUS`](#status) | 0x0      |        4 | X-DMA Status reg |

## STATUS
X-DMA Status reg
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "OPERATIONAL", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 130}}
```

|  Bits  |  Type  |  Reset  | Name        | Description            |
|:------:|:------:|:-------:|:------------|:-----------------------|
|  31:1  |        |         |             | Reserved               |
|   0    |   rw   |    x    | OPERATIONAL | Operational FSM status |

