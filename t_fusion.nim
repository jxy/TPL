import tpl

type
  Ix = IndexType(0,2)
  V = Tensor(float, [Ix])
  M = Tensor(float, [Ix, Ix])
var
  i, j, k: Ix.Dummy
  x: float
  v1, v2, v3, v4, v5: V
  m1, m2, m3, m4: M

prepareDummy(Ix)
tensorOpsSilent:
  echo "Fusion should separate overlapping statements."
  v1[i] = 0.1 * i
  m1[i,j] = 0.1 * j + i
  v2 += m1 * v1
  v3 += v2 * m1
  echo "v1[i] = 0.1 * i = ", v1
  echo "m1[i,j] = 0.1 * j + i =\n", m1
  echo "v2 += m1 * v1 = ", v2
  echo "v3 += v2 * m1 = ", v3
  echo "Correct result should be:"
  v4 += m1 * v1
  echo "v4 += m1 * v1 = ", v4
  v5 += v4 * m1
  echo "v5 += v4 * m1 = ", v5
  echo "\nTest matrix multiplication:"
  m2[i,j] = 0.1 * i + j
  m3 += m1 * m2
  echo "m2[i,j] = 0.1 * i + j =\n", m2
  echo "m3 += m1 * m2 =\n", m3
  echo "Correct result should be:"
  m4 += m1 * m2
  echo "m4 += m1 * m2 =\n", m4
  assert $v2 == $v4
  assert $v3 == $v5
  assert $m3 == $m4
tensorOps:
  echo "\nTry fused accumulations (check the compiler output!)"
  x = 0
  v1 = m1
  x += v1
tensorOpsSilent:
  echo "v1 = m1 = ", v1
  echo "x += v1 = ", x
  assert v1[i] == 1.1*i
  assert x == 1.1*3
  echo "\nAnother test with an automatically split summation."
  m3[i,k] = 0
  m3[i,k] += m1[i,j] * m2[j,i]
  echo "m3[i,k] = m1[i,j] * m2[j,i] =\n", m3
  assert m3[Ix.index 0,Ix.index 0] == 0.01 + 0.2*0.2
  assert m3[Ix.index 1,Ix.index 0] == 3.65
  assert m3[Ix.index 2,Ix.index 0] == 13.25
  assert m3[i,Ix.index 0] == m3[i,j]
  v3 = 0
tensorOps:
  echo "\nThese should fuse completely (check the compiler output!)"
  v2 = 0
  v2 += v1 + 0.1
  v3 += v2 * m1
tensorOpsSilent:
  echo "v2 = 0; v2 += v1 + 0.1 = ", v2
  echo "v3 += v2 * m1 = ", v3
  assert v2[i] == 1.1*i+0.1
  v4 = v2 * m1
  assert v4[i] == v3[i]