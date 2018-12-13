defprotocol Heap do
  def get_min(heap)
  def size(heap)
  def to_list(heap)
  def insert(heap, item)
  def delete_min(heap)
end
