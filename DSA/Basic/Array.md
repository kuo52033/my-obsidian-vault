# Array — Coding Interview Cheat Sheet

> Source: [Tech Interview Handbook — Array](https://www.techinterviewhandbook.org/algorithms/array/)

---

## 📌 What is an Array?

An array is a contiguous block of memory holding elements of the same type. It's the most fundamental data structure and appears in nearly every interview.

---

## ⏱ Time Complexity

|Operation|Big-O|Notes|
|---|---|---|
|Access|O(1)|Direct index lookup|
|Search|O(n)|Linear scan (unsorted)|
|Search (sorted)|O(log n)|Binary search|
|Insert (end)|O(1)|Amortized for dynamic arrays|
|Insert (middle)|O(n)|Must shift elements|
|Delete (end)|O(1)||
|Delete (middle)|O(n)|Must shift elements|

---

## 🧠 Core Techniques

### 1. Two Pointers

Use two indices moving toward each other (or in the same direction) to reduce O(n²) to O(n).

**When to use:** Sorted arrays, pair sums, palindrome checks, removing duplicates.

```python
left, right = 0, len(arr) - 1
while left < right:
    # process arr[left] and arr[right]
    left += 1
    right -= 1
```

---

### 2. Sliding Window

Maintain a window of elements; expand/shrink it to satisfy a constraint.

**When to use:** Subarray problems, max/min subarray of size k, longest subarray with condition.

```python
left = 0
for right in range(len(arr)):
    # expand window
    while <window invalid>:
        left += 1  # shrink window
    # update answer
```

---

### 3. Prefix Sum

Precompute cumulative sums to answer range queries in O(1).

**When to use:** Subarray sum queries, count subarrays with target sum.

```python
prefix = [0] * (len(arr) + 1)
for i, val in enumerate(arr):
    prefix[i + 1] = prefix[i] + val

# sum from index l to r (inclusive):
range_sum = prefix[r + 1] - prefix[l]
```

---

### 4. Sorting + Binary Search

Sorting enables O(log n) lookups and simplifies many problems.

```python
arr.sort()
import bisect
idx = bisect.bisect_left(arr, target)
```

---

### 5. Hash Map / Hash Set

Trade space for O(1) lookups. Extremely common in array problems.

**When to use:** Frequency counts, finding duplicates, two-sum style problems.

```python
seen = {}
for val in arr:
    complement = target - val
    if complement in seen:
        return [seen[complement], val]
    seen[val] = val
```

---

## ⚠️ Corner Cases to Always Check

- [ ] Empty array `[]`
- [ ] Array with a single element
- [ ] Array with all duplicate elements
- [ ] Array with negative numbers
- [ ] Array already sorted (ascending or descending)
- [ ] Off-by-one errors at boundaries

---

## 🔥 Essential Problems

|Problem|Pattern|Difficulty|
|---|---|---|
|Two Sum|Hash Map|Easy|
|Best Time to Buy and Sell Stock|Sliding Window / Greedy|Easy|
|Contains Duplicate|Hash Set|Easy|
|Product of Array Except Self|Prefix/Suffix Product|Medium|
|Maximum Subarray (Kadane's)|DP / Greedy|Medium|
|3Sum|Two Pointers + Sort|Medium|
|Container With Most Water|Two Pointers|Medium|
|Sliding Window Maximum|Monotonic Deque|Hard|
|Trapping Rain Water|Two Pointers / Stack|Hard|

---

## 💡 Interview Tips

- **Clarify bounds:** Ask about constraints — size, value range, duplicates allowed?
- **Think about sorted vs unsorted:** Sorting often unlocks simpler solutions.
- **Trade space for time:** A hash map is almost always worth the O(n) space.
- **Sliding window over nested loops:** If you find yourself writing O(n²), ask "can a window help here?"
- **Draw it out:** Visualize index movement for two-pointer and window problems.

---

## 🔗 Related Topics

- [[Sorting]]
- [[Binary Search]]
- [[Hash Table]]
- [[Dynamic Programming]]
- [[String]] _(strings are essentially character arrays)_