import std/options


type
  Iterator*[T] = object
    elements: seq[T]
    curIndex: int = 0

proc newIterator*[T](elements: seq[T]): Iterator[T] =
  return Iterator[T](elements: elements)

proc next*[T](itr: var Iterator[T]): Option[T] =
  let resIdx = itr.curIndex
  if resIdx >= itr.elements.len:
    return none(T)

  itr.curIndex += 1

  return some(itr.elements[resIdx])

proc peek*[T](itr: var Iterator[T]): Option[T] =
  if itr.curIndex >= itr.elements.len:
    return none(T)

  return some(itr.elements[itr.curIndex])

proc peekNext*[T](itr: var Iterator[T]): Option[T] =
  let peekIdx = itr.curIndex + 1
  if peekIdx >= itr.elements.len:
    return none(T)

  return some(itr.elements[peekIdx])
