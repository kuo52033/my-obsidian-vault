```python
def bubble_sort(nums):
    n = len(nums)

    for i in range(n):
        for j in range(n - i - 1):  # 每輪少看最後 i 個（已排序）
            if nums[j] > nums[j+1]:
                nums[j], nums[j+1] = nums[j+1], nums[j]

    return nums
```
### 複雜度 

|       |       |
| ----- | ----- |
| Time  | O(n²) |
| Space | O(1)  |
