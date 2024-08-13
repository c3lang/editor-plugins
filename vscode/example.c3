// Copyright (c) 2023 Christoffer Lerno and contributors. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.


// This is an example file. The original is at https://github.com/c3lang/c3intellij.git
// As in Revision 2023-06-02 - https://c3-lang.org/references/development/changes/#revision-2023-06-02)
// 'typedef' was replaced by 'def'

module std::core::bitorder;

// This module contains types of different endianness.
// *BE types represent big-endian types
// *LE types represent little-endian types.

bitstruct ShortBE : short @bigendian
{
	short val : 0..15;
}

bitstruct UShortBE : ushort @bigendian
{
	ushort val : 0..15;
}

bitstruct IntBE : int @bigendian
{
	int val : 0..31;
}

bitstruct UIntBE : int @bigendian
{
	uint val : 0..31;
}

bitstruct LongBE : long @bigendian
{
	long val : 0..63;
}

bitstruct ULongBE : ulong @bigendian
{
	ulong val : 0..63;
}

bitstruct Int128BE : int128 @bigendian
{
	int128 val : 0..127;
}

bitstruct UInt128BE : uint128 @bigendian
{
	uint128 val : 0..127;
}

bitstruct ShortLE : short @littleendian
{
	short val : 0..15;
}

bitstruct UShortLE : ushort @littleendian
{
	ushort val : 0..15;
}

bitstruct IntLE : int @littleendian
{
	int val : 0..31;
}

bitstruct UIntLE : int @littleendian
{
	uint val : 0..31;
}

bitstruct LongLE : long @littleendian
{
	long val : 0..63;
}

bitstruct ULongLE : ulong @littleendian
{
	ulong val : 0..63;
}

bitstruct Int128LE : int128 @littleendian
{
	int128 val : 0..127;
}

bitstruct UInt128LE : uint128 @littleendian
{
	uint128 val : 0..127;
}
module std::collections::enummap<Enum, ValueType>;

struct EnumMap
{
    ValueType[Enum.len] values;
}

fn void EnumMap.init(EnumMap* this, ValueType init_value)
{
    foreach(&a : this.values)
    {
        *a = init_value;
    }
}

fn uint EnumMap.len(EnumMap* this) @operator(len) => this.values.len;
fn ValueType EnumMap.get(EnumMap* this, Enum key) @operator([]) => this.values[key.ordinal];
fn void EnumMap.set(EnumMap* this, Enum key, ValueType value) @operator([]=) => this.values[key.ordinal] = value;
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.

/**
 * @require Enum.kindof == TypeKind.ENUM : "Only enums maybe be used with an enumset"
 **/
module std::collections::enumset<Enum>;


$switch
$case (Enum.elements > 128):
def EnumSetType @private = char[(Enum.elements + 7) / 8];
const IS_CHAR_ARRAY = true;
$case (Enum.elements > 64):
def EnumSetType @private = uint128;
const IS_CHAR_ARRAY = false;
$case (Enum.elements > 32 || $$C_INT_SIZE > 32):
def EnumSetType @private = ulong;
const IS_CHAR_ARRAY = false;
$case (Enum.elements > 16 || $$C_INT_SIZE > 16):
def EnumSetType @private = uint;
const IS_CHAR_ARRAY = false;
$case (Enum.elements > 8 || $$C_INT_SIZE > 8):
def EnumSetType @private = ushort;
const IS_CHAR_ARRAY = false;
$default:
def EnumSetType @private = char;
const IS_CHAR_ARRAY = false;
$endswitch

def EnumSet = distinct EnumSetType;

fn void EnumSet.add(EnumSet* this, Enum v)
{
$if (IS_CHAR_ARRAY)
	(*this)[v / 8] |= (char)(1u << (v % 8));
$else
    *this = (EnumSet)((EnumSetType)*this | 1u << (EnumSetType)v);
$endif
}

fn void EnumSet.clear(EnumSet* this)
{
$if (IS_CHAR_ARRAY)
	*this = {};
$else
    *this = 0;
$endif
}

fn bool EnumSet.remove(EnumSet* this, Enum v)
{
$if (IS_CHAR_ARRAY)
	if (!this.has(v) @inline) return false;
	(*this)[v / 8] &= (char)~(1 << (v % 8));
	return true;
$else
    EnumSetType old = (EnumSetType)*this;
    EnumSetType new = old & ~(1u << (EnumSetType)v);
    *this = (EnumSet)new;
    return old != new;
$endif
}

fn bool EnumSet.has(EnumSet* this, Enum v)
{
$if (IS_CHAR_ARRAY)
	return (bool)(((*this)[v / 8] << (v % 8)) & 0x01);
$else
    return ((EnumSetType)*this & (1u << (EnumSetType)v)) != 0;
$endif
}

fn void EnumSet.add_all(EnumSet* this, EnumSet s)
{
$if (IS_CHAR_ARRAY)
	foreach (i, c : s) (*this)[i] |= c;
$else
    *this = (EnumSet)((EnumSetType)*this | (EnumSetType)s);
$endif
}

fn void EnumSet.retain_all(EnumSet* this, EnumSet s)
{
$if (IS_CHAR_ARRAY)
	foreach (i, c : s) (*this)[i] &= c;
$else
    *this = (EnumSet)((EnumSetType)*this & (EnumSetType)s);
$endif
}

fn void EnumSet.remove_all(EnumSet* this, EnumSet s)
{
$if (IS_CHAR_ARRAY)
	foreach (i, c : s) (*this)[i] &= ~c;
$else
    *this = (EnumSet)((EnumSetType)*this & ~(EnumSetType)s);
$endif
}

fn EnumSet EnumSet.and_of(EnumSet* this, EnumSet s)
{
$if (IS_CHAR_ARRAY)
	EnumSet copy = *this;
	copy.retain_all(s);
	return copy;
$else
    return (EnumSet)((EnumSetType)*this & (EnumSetType)s);
$endif
}

fn EnumSet EnumSet.or_of(EnumSet* this, EnumSet s)
{
$if (IS_CHAR_ARRAY)
	EnumSet copy = *this;
	copy.add_all(s);
	return copy;
$else
    return (EnumSet)((EnumSetType)*this | (EnumSetType)s);
$endif
}


fn EnumSet EnumSet.diff_of(EnumSet* this, EnumSet s)
{
$if (IS_CHAR_ARRAY)
	EnumSet copy = *this;
	copy.remove_all(s);
	return copy;
$else
    return (EnumSet)((EnumSetType)*this & ~(EnumSetType)s);
$endif
}

fn EnumSet EnumSet.xor_of(EnumSet* this, EnumSet s)
{
$if (IS_CHAR_ARRAY)
	EnumSet copy = *this;
	foreach (i, c : s) copy[i] ^= c;
	return copy;
$else
    return (EnumSet)((EnumSetType)*this ^ (EnumSetType)s);
$endif
}
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::collections::linkedlist<Type>;

struct Node @private
{
    Node *next;
    Node *prev;
    Type value;
}

struct LinkedList
{
    Allocator *allocator;
    usz size;
    Node *_first;
    Node *_last;
}

fn void LinkedList.push(LinkedList* list, Type value)
{
    list.link_first(value);
}

fn void LinkedList.push_last(LinkedList* list, Type value)
{
	list.link_last(value);
}

fn void LinkedList.init(LinkedList* list, Allocator* using = mem::heap())
{
	*list = { .allocator = using };
}

fn void LinkedList.tinit(LinkedList* list) => list.init(mem::temp()) @inline;

/**
 * @require list.allocator
 **/
macro void LinkedList.@free_node(LinkedList &list, Node* node) @private
{
	list.allocator.free(node)!!;
}
macro Node* LinkedList.@alloc_node(LinkedList &list) @private
{
	if (!list.allocator) list.allocator = mem::heap();
	return malloc(Node, .using = list.allocator);
}

fn void LinkedList.link_first(LinkedList* list, Type value) @private
{
    Node* first = list._first;
    Node* new_node = list.@alloc_node();
    *new_node = { .next = first, .value = value };
    list._first = new_node;
    if (!first)
    {
        list._last = new_node;
    }
    else
    {
        first.prev = new_node;
    }
    list.size++;
}

fn void LinkedList.link_last(LinkedList* list, Type value) @private
{
    Node *last = list._last;
    Node *new_node = list.@alloc_node();
    *new_node = { .prev = last, .value = value };
    list._last = new_node;
    if (!last)
    {
        list._first = new_node;
    }
    else
    {
        last.next = new_node;
    }
    list.size++;
}

fn Type! peek(LinkedList* list) => list.first() @inline;
fn Type! peek_last(LinkedList* list) => list.last() @inline;

fn Type! LinkedList.first(LinkedList *list)
{
	if (!list._first) return IteratorResult.NO_MORE_ELEMENT?;
	return list._first.value;
}

fn Type! LinkedList.last(LinkedList* list)
{
	if (!list._last) return IteratorResult.NO_MORE_ELEMENT?;
	return list._last.value;
}

fn void LinkedList.free(LinkedList* list) => list.clear() @inline;

fn void LinkedList.clear(LinkedList* list)
{
    for (Node* node = list._first; node != null;)
    {
        Node* next = node.next;
        list.@free_node(node);
        node = next;
    }
    list._first = null;
    list._last = null;
    list.size = 0;
}

fn usz LinkedList.len(LinkedList* list) @inline => list.size;

/**
 * @require index < list.size
 **/
macro Node* LinkedList.node_at_index(LinkedList* list, usz index)
{
	if (index * 2 >= list.size)
	{
	    Node* node = list._last;
	    index = list.size - index - 1;
        while (index--) node = node.prev;
        return node;
	}
    Node* node = list._first;
    while (index--) node = node.next;
    return node;
}
/**
 * @require index < list.size
 **/
fn Type LinkedList.get(LinkedList* list, usz index)
{
	return list.node_at_index(index).value;
}

/**
 * @require index < list.size
 **/
fn void LinkedList.set(LinkedList* list, usz index, Type element)
{
	list.node_at_index(index).value = element;
}

/**
 * @require index < list.size
 **/
fn void LinkedList.remove(LinkedList* list, usz index)
{
	list.unlink(list.node_at_index(index));
}

/**
 * @require index <= list.size
 **/
fn void LinkedList.insert(LinkedList* list, usz index, Type element)
{
	switch (index)
	{
		case 0:
			list.push(element);
		case list.size:
			list.push_last(element);
		default:
			list.link_before(list.node_at_index(index), element);
	}
}
/**
 * @require succ != null
 **/
fn void LinkedList.link_before(LinkedList *list, Node *succ, Type value) @private
{
    Node* pred = succ.prev;
    Node* new_node = malloc(Node);
    *new_node = { .prev = pred, .next = succ, .value = value };
    succ.prev = new_node;
    if (!pred)
    {
        list._first = new_node;
    }
    else
    {
        pred.next = new_node;
    }
    list.size++;
}

/**
 * @require list && list._first
 **/
fn void LinkedList.unlink_first(LinkedList* list) @private
{
	Node* f = list._first;
    Node* next = f.next;
    list.@free_node(f);
    list._first = next;
    if (!next)
    {
        list._last = null;
    }
    else
    {
        next.prev = null;
    }
    list.size--;
}

fn bool LinkedList.remove_value(LinkedList* list, Type t)
{
    for (Node* node = list._first; node != null; node = node.next)
    {
        if (node.value == t)
        {
            list.unlink(node);
            return true;
        }
    }
    return false;
}

fn bool LinkedList.remove_last_value(LinkedList* list, Type t)
{
    for (Node* node = list._last; node != null; node = node.prev)
    {
        if (node.value == t)
        {
            list.unlink(node);
            return true;
        }
    }
    return false;
}

/**
 * @param [&inout] list
 **/
fn Type! LinkedList.pop(LinkedList* list)
{
	if (!list._first) return IteratorResult.NO_MORE_ELEMENT?;
	defer list.unlink_first();
	return list._first.value;
}

/**
 * @param [&inout] list
 **/
fn void! LinkedList.remove_last(LinkedList* list)
{
	if (!list._first) return IteratorResult.NO_MORE_ELEMENT?;
	list.unlink_last();
}

/**
 * @param [&inout] list
 **/
fn void! LinkedList.remove_first(LinkedList* list)
{
	if (!list._first) return IteratorResult.NO_MORE_ELEMENT?;
	list.unlink_first();
}

/**
 * @param [&inout] list
 * @require list._last
 **/
fn void LinkedList.unlink_last(LinkedList *list) @inline @private
{
	Node* l = list._last;
    Node* prev = l.prev;
    list._last = prev;
    list.@free_node(l);
    if (!prev)
    {
        list._first = null;
    }
    else
    {
        prev.next = null;
    }
    list.size--;
}

/**
 * @require list != null, x != null
 **/
fn void LinkedList.unlink(LinkedList* list, Node* x) @private
{
    Node* next = x.next;
    Node* prev = x.prev;
    if (!prev)
    {
        list._first = next;
    }
    else
    {
        prev.next = next;
    }
    if (!next)
    {
        list._last = prev;
    }
    else
    {
        next.prev = prev;
    }
    list.@free_node(x);
    list.size--;
}
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::collections::list<Type>;
import std::math;

def ElementPredicate = fn bool(Type *type);

struct List
{
    usz size;
    usz capacity;
    Allocator *allocator;
    Type *entries;
}

/**
 * @require using != null "A valid allocator must be provided"
 **/
fn void List.init(List* list, usz initial_capacity = 16, Allocator* using = mem::heap())
{
	list.allocator = using;
	list.size = 0;
	if (initial_capacity > 0)
	{
		initial_capacity = math::next_power_of_2(initial_capacity);
		list.entries = malloc_aligned(Type, initial_capacity, .alignment = Type[1].alignof, .using = using)!!;
	}
	else
	{
		list.entries = null;
	}
	list.capacity = initial_capacity;
}

fn void List.tinit(List* list, usz initial_capacity = 16)
{
	list.init(initial_capacity, mem::temp()) @inline;
}

fn void List.push(List* list, Type element) @inline
{
    list.append(element);
}

fn void List.append(List* list, Type element)
{
    list.ensure_capacity();
    list.entries[list.size++] = element;
}

/**
 * @require list.size > 0
 */
fn Type List.pop(List* list)
{
    return list.entries[--list.size];
}

fn void List.clear(List* list)
{
    list.size = 0;
}

/**
 * @require list.size > 0
 */
fn Type List.pop_first(List* list)
{
    Type value = list.entries[0];
    list.remove_at(0);
    return value;
}

fn void List.remove_at(List* list, usz index)
{
    for (usz i = index + 1; i < list.size; i++)
    {
        list.entries[i - 1] = list.entries[i];
    }
    list.size--;
}

fn void List.add_all(List* list, List* other_list)
{
	if (!other_list.size) return;
	list.reserve(other_list.size);
	foreach (&value : other_list)
	{
	    list.entries[list.size++] = *value;
	}
}


fn Type[] List.to_array(List* list, Allocator* using = mem::heap())
{
	if (!list.size) return Type[] {};
	Type[] result = malloc(Type, list.size, .using = using);
	result[..] = list.entries[:list.size];
	return result;
}

/**
 * Reverse the elements in a list.
 *
 * @param [&inout] list "The list to reverse"
 **/
fn void List.reverse(List* list)
{
	if (list.size < 2) return;
	usz half = list.size / 2U;
	usz end = list.size - 1;
	for (usz i = 0; i < half; i++)
	{
		@swap(list.entries[i], list.entries[end - i]);
	}
}

fn Type[] List.array_view(List* list)
{
	return list.entries[:list.size];
}

fn void List.add_array(List* list, Type[] array)
{
	if (!array.len) return;
	list.reserve(array.len);
	foreach (&value : array)
	{
	    list.entries[list.size++] = *value;
	}
}

fn void List.push_front(List* list, Type type) @inline
{
    list.insert_at(0, type);
}

fn void List.insert_at(List* list, usz index, Type type)
{
    list.ensure_capacity();
    for (usz i = list.size; i > index; i--)
    {
        list.entries[i] = list.entries[i - 1];
    }
    list.size++;
    list.entries[index] = type;
}

/**
 * @require index < list.size
 **/
fn void List.set_at(List* list, usz index, Type type)
{
    list.entries[index] = type;
}

fn void List.remove_last(List* list)
{
    list.size--;
}

fn void List.remove_first(List* list)
{
    list.remove_at(0);
}

fn Type* List.first(List* list)
{
    return list.size ? &list.entries[0] : null;
}

fn Type* List.last(List* list)
{
    return list.size ? &list.entries[list.size - 1] : null;
}

fn bool List.is_empty(List* list)
{
    return !list.size;
}

fn usz List.len(List* list) @operator(len)
{
    return list.size;
}

fn Type List.get(List* list, usz index)
{
    return list.entries[index];
}

fn void List.free(List* list)
{
	if (!list.allocator) return;
    free_aligned(list.entries, .using = list.allocator);
    list.capacity = 0;
    list.size = 0;
    list.entries = null;
}

fn void List.swap(List* list, usz i, usz j)
{
	@swap(list.entries[i], list.entries[j]);
}

/**
 * @param [&inout] list "The list to remove elements from"
 * @param filter "The function to determine if it should be removed or not"
 * @return "the number of deleted elements"
 **/
fn usz List.remove_if(List* list, ElementPredicate filter)
{
	usz size = list.size;
	for (usz i = size; i > 0; i--)
	{
		if (filter(&list.entries[i - 1])) continue;
		for (usz j = i; j < size; j++)
		{
			list.entries[j - 1] = list.entries[j];
		}
		list.size--;
	}
	return size - list.size;
}

/**
 * @param [&inout] list "The list to remove elements from"
 * @param selection "The function to determine if it should be kept or not"
 * @return "the number of deleted elements"
 **/
fn usz List.retain_if(List* list, ElementPredicate selection)
{
	usz size = list.size;
	for (usz i = size; i > 0; i--)
	{
		if (!selection(&list.entries[i - 1])) continue;
		for (usz j = i; j < size; j++)
		{
			list.entries[j - 1] = list.entries[j];
		}
		list.size--;
	}
	return size - list.size;
}


/**
 * Reserve at least min_capacity
 **/
fn void List.reserve(List* list, usz min_capacity)
{
	if (!min_capacity) return;
	if (list.capacity >= min_capacity) return;
	if (!list.allocator) list.allocator = mem::heap();
	min_capacity = math::next_power_of_2(min_capacity);
    list.entries = realloc_aligned(list.entries, Type.sizeof * min_capacity, .alignment = Type[1].alignof, .using = list.allocator) ?? null;
	list.capacity = min_capacity;
}

macro Type List.@item_at(List &list, usz index) @operator([])
{
    return list.entries[index];
}

fn Type* List.get_ref(List* list, usz index) @operator(&[]) @inline
{
    return &list.entries[index];
}

fn void List.ensure_capacity(List* list, usz added = 1) @inline @private
{
	usz new_size = list.size + added;
    if (list.capacity > new_size) return;

	assert(new_size < usz.max / 2U);
	usz new_capacity = list.capacity ? 2U * list.capacity : 16U;
	while (new_size >= new_capacity) new_capacity *= 2U;
	list.reserve(new_capacity);
}

// Functions for equatable types

$if (types::is_equatable_type(Type))

fn usz! List.index_of(List* list, Type type)
{
	foreach (i, v : list)
	{
		if (v == type) return i;
	}
	return SearchResult.MISSING?;
}

fn usz! List.rindex_of(List* list, Type type)
{
	foreach_r (i, v : list)
	{
		if (v == type) return i;
	}
	return SearchResult.MISSING?;
}

fn bool List.equals(List* list, List other_list)
{
	if (list.size != other_list.size) return false;
	foreach (i, v : list)
	{
		if (v != other_list.entries[i]) return false;
	}
	return true;
}

/**
 * Check for presence of a value in a list.
 *
 * @param [&in] list "the list to find elements in"
 * @param value "The value to search for"
 * @return "True if the value is found, false otherwise"
 **/
fn bool List.contains(List* list, Type value)
{
	foreach (i, v : list)
	{
		if (v == value) return true;
	}
	return false;
}


/**
 * @param [&inout] list "The list to remove elements from"
 * @param value "The value to remove"
 * @return "the number of deleted elements."
 **/
fn usz List.remove(List* list, Type value)
{
	usz size = list.size;
	for (usz i = size; i > 0; i--)
	{
		if (list.entries[i - 1] != value) continue;
		for (usz j = i; j < size; j++)
		{
			list.entries[j - 1] = list.entries[j];
		}
		list.size--;
	}
	return size - list.size;
}

fn void List.remove_all(List* list, List* other_list)
{
	if (!other_list.size) return;
	foreach (v : other_list) list.remove(v);
}


$endif

$if (Type.kindof == POINTER)

/**
 * @param [&in] list
 * @return "The number non-null values in the list"
 **/
fn usz List.compact_count(List* list)
{
	usz vals = 0;
	foreach (v : list) if (v) vals++;
	return vals;
}

fn usz List.compact(List* list)
{
	usz size = list.size;
	for (usz i = size; i > 0; i--)
	{
		if (list.entries[i - 1]) continue;
		for (usz j = i; j < size; j++)
		{
			list.entries[j - 1] = list.entries[j];
		}
		list.size--;
	}
	return size - list.size;
}

$endif
// Copyright (c) 2023 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::collections::map<Key, Value>;
import std::math;

const uint DEFAULT_INITIAL_CAPACITY = 16;
const uint MAXIMUM_CAPACITY = 1u << 31;
const float DEFAULT_LOAD_FACTOR = 0.75;


struct HashMap
{
	Entry*[] table;
	Allocator* allocator;
	uint count; // Number of elements
	uint threshold; // Resize limit
	float load_factor;
}

/**
 * @require capacity > 0 "The capacity must be 1 or higher"
 * @require load_factor > 0.0 "The load factor must be higher than 0"
 * @require !map.allocator "Map was already initialized"
 * @require capacity < MAXIMUM_CAPACITY "Capacity cannot exceed maximum"
 * @require using != null "The allocator must be non-null"
 **/
fn void HashMap.init(HashMap* map, uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR, Allocator* using = mem::heap())
{
	capacity = math::next_power_of_2(capacity);
	map.allocator = using;
	map.load_factor = load_factor;
	map.threshold = (uint)(capacity * load_factor);
	map.table = calloc(Entry*, capacity, .using = using);
}

/**
 * @require capacity > 0 "The capacity must be 1 or higher"
 * @require load_factor > 0.0 "The load factor must be higher than 0"
 * @require !map.allocator "Map was already initialized"
 * @require capacity < MAXIMUM_CAPACITY "Capacity cannot exceed maximum"
 **/
fn void HashMap.tinit(HashMap* map, uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR)
{
	map.init(capacity, load_factor, mem::temp());
}

fn void HashMap.init_from_map(HashMap* map, HashMap* other_map, Allocator* using = mem::heap())
{
	map.init(other_map.table.len, other_map.load_factor, using);
	map.put_all_for_create(other_map);
}

fn void HashMap.tinit_from_map(HashMap* map, HashMap* other_map)
{
	map.init_from_map(other_map, mem::temp()) @inline;
}

fn bool HashMap.is_empty(HashMap* map) @inline
{
	return !map.count;
}

fn Value*! HashMap.get_ref(HashMap* map, Key key)
{
	if (!map.count) return SearchResult.MISSING?;
	uint hash = rehash(key.hash());
	for (Entry *e = map.table[index_for(hash, map.table.len)]; e != null; e = e.next)
	{
		if (e.hash == hash && equals(key, e.key)) return &e.value;
	}
	return SearchResult.MISSING?;
}

fn Entry*! HashMap.get_entry(HashMap* map, Key key)
{
	if (!map.count) return SearchResult.MISSING?;
	uint hash = rehash(key.hash());
	for (Entry *e = map.table[index_for(hash, map.table.len)]; e != null; e = e.next)
	{
		if (e.hash == hash && equals(key, e.key)) return e;
	}
	return SearchResult.MISSING?;
}

/**
 * Get the value or update and
 **/
macro Value HashMap.@get_or_set(HashMap* map, Key key, Value #expr)
{
	if (!map.count)
	{
		Value val = #expr;
		map.set(key, val);
		return val;
	}
	uint hash = rehash(key.hash());
	uint index = index_for(hash, map.table.len);
	for (Entry *e = map.table[index]; e != null; e = e.next)
	{
		if (e.hash == hash && equals(key, e.key)) return e.value;
	}
	Value val = #expr;
	map.add_entry(hash, key, val, index);
	return val;
}

fn Value! HashMap.get(HashMap* map, Key key) @operator([])
{
	return *map.get_ref(key) @inline;
}

fn bool HashMap.has_key(HashMap* map, Key key)
{
	return @ok(map.get_ref(key));
}

fn bool HashMap.set(HashMap* map, Key key, Value value) @operator([]=)
{
	// If the map isn't initialized, use the defaults to initialize it.
	if (!map.allocator)
	{
		map.init();
	}
	uint hash = rehash(key.hash());
	uint index = index_for(hash, map.table.len);
	for (Entry *e = map.table[index]; e != null; e = e.next)
	{
		if (e.hash == hash && equals(key, e.key))
		{
			e.value = value;
			return true;
		}
	}
	map.add_entry(hash, key, value, index);
	return false;
}

fn void! HashMap.remove(HashMap* map, Key key) @maydiscard
{
	if (!map.remove_entry_for_key(key)) return SearchResult.MISSING?;
}

fn void HashMap.clear(HashMap* map)
{
	if (!map.count) return;
	foreach (Entry** &entry_ref : map.table)
	{
		Entry* entry = *entry_ref;
		if (!entry) continue;
		map.free_internal(entry);
		*entry_ref = null;
	}
	map.count = 0;
}

fn void HashMap.free(HashMap* map)
{
	if (!map.allocator) return;
	map.clear();
	map.free_internal(map.table.ptr);
	map.table = Entry*[] {};
}

fn Key[] HashMap.key_tlist(HashMap* map)
{
	return map.key_list(mem::temp()) @inline;
}

fn Key[] HashMap.key_list(HashMap* map, Allocator* using = mem::heap())
{
	if (!map.count) return Key[] {};

	Key[] list = calloc(Key, map.count, .using = using);
	usz index = 0;
	foreach (Entry* entry : map.table)
	{
		while (entry)
		{
			list[index++] = entry.key;
			entry = entry.next;
		}
	}
	return list;
}

fn Value[] HashMap.value_tlist(HashMap* map)
{
	return map.value_list(mem::temp()) @inline;
}

fn Value[] HashMap.value_list(HashMap* map, Allocator* using = mem::heap())
{
	if (!map.count) return Value[] {};
	Value[] list = calloc(Value, map.count, .using = using);
	usz index = 0;
	foreach (Entry* entry : map.table)
	{
		while (entry)
		{
			list[index++] = entry.value;
			entry = entry.next;
		}
	}
	return list;
}

$if (types::is_equatable(Value))
fn bool HashMap.has_value(HashMap* map, Value v)
{
	if (!map.count) return false;
	foreach (Entry* entry : map.table)
	{
		while (entry)
		{
			if (equals(v, entry.value)) return true;
			entry = entry.next;
		}
	}
	return false;
}
$endif

// --- private methods

fn void HashMap.add_entry(HashMap* map, uint hash, Key key, Value value, uint bucket_index) @private
{
	Entry* entry = malloc(Entry, .using = map.allocator);
	*entry = { .hash = hash, .key = key, .value = value, .next = map.table[bucket_index] };
	map.table[bucket_index] = entry;
	if (map.count++ >= map.threshold)
	{
		map.resize(map.table.len * 2);
    }
}

fn void HashMap.resize(HashMap* map, uint new_capacity) @private
{
	Entry*[] old_table = map.table;
	uint old_capacity = old_table.len;
	if (old_capacity == MAXIMUM_CAPACITY)
	{
		map.threshold = uint.max;
		return;
	}
	Entry*[] new_table = calloc(Entry*, new_capacity, .using = map.allocator);
	map.transfer(new_table);
	map.table = new_table;
	map.free_internal(old_table.ptr);
	map.threshold = (uint)(new_capacity * map.load_factor);
}

fn uint rehash(uint hash) @inline @private
{
    hash ^= (hash >> 20) ^ (hash >> 12);
    return hash ^ ((hash >> 7) ^ (hash >> 4));
}

macro uint index_for(uint hash, uint capacity) @private
{
	return hash & (capacity - 1);
}

fn void HashMap.transfer(HashMap* map, Entry*[] new_table) @private
{
	Entry*[] src = map.table;
    uint new_capacity = new_table.len;
    foreach (uint j, Entry *e : src)
    {
        if (!e) continue;
        do
        {
            Entry* next = e.next;
            uint i = index_for(e.hash, new_capacity);
            e.next = new_table[i];
            new_table[i] = e;
            e = next;
        }
        while (e);
    }
}

fn void HashMap.put_all_for_create(HashMap* map, HashMap* other_map) @private
{
	if (!other_map.count) return;
    foreach (Entry *e : other_map.table)
    {
        if (!e) continue;
        map.put_for_create(e.key, e.value);
    }
}

fn void HashMap.put_for_create(HashMap* map, Key key, Value value) @private
{
    uint hash = rehash(key.hash());
    uint i = index_for(hash, map.table.len);
	for (Entry *e = map.table[i]; e != null; e = e.next)
	{
		if (e.hash == hash && equals(key, e.key))
		{
			e.value = value;
			return;
		}
	}
	map.create_entry(hash, key, value, i);
}

fn void HashMap.free_internal(HashMap* map, void* ptr) @inline @private
{
	map.allocator.free(ptr)!!;
}

fn bool HashMap.remove_entry_for_key(HashMap* map, Key key) @private
{
	uint hash = rehash(key.hash());
	uint i = index_for(hash, map.table.len);
	Entry* prev = map.table[i];
	Entry* e = prev;
	while (e)
	{
		Entry *next = e.next;
		if (e.hash == hash && equals(key, e.key))
		{
			map.count--;
			if (prev == e)
			{
				map.table[i] = next;
			}
			else
			{
				prev.next = next;
			}
			map.free_internal(e);
			return true;
		}
		prev = e;
		e = next;
	}
	return false;
}

fn void HashMap.create_entry(HashMap* map, uint hash, Key key, Value value, int bucket_index) @private
{
	Entry *e = map.table[bucket_index];
	Entry* entry = malloc(Entry, .using = map.allocator);
	*entry = { .hash = hash, .key = key, .value = value, .next = map.table[bucket_index] };
	map.table[bucket_index] = entry;
	map.count++;
}

struct Entry
{
	uint hash;
	Key key;
	Value value;
	Entry* next;
}
// Copyright (c) 2023 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::collections::object;
import std::collections::map;
import std::collections::list;
import std::io;

const Object TRUE_OBJECT = { .b = true, .type = bool.typeid };
const Object FALSE_OBJECT = { .b = false, .type = bool.typeid };
const Object NULL_OBJECT = { .type = void*.typeid };

struct Object
{
	typeid type;
	Allocator* allocator;
	union
	{
		uint128 i;
		double f;
		bool b;
		String s;
		void* other;
		ObjectInternalList array;
		ObjectInternalMap map;
	}
}

static initialize
{
	io::formatter_register_type(Object);
}

fn void! Object.to_format(Object* o, Formatter* formatter)
{
	switch (o.type)
	{
		case void:
			formatter.printf("{}")!;
		case void*:
			formatter.printf("null")!;
		case String:
			formatter.printf(`"%s"`, o.s)!;
		case bool:
			formatter.printf(o.b ? "true" : "false")!;
		case ObjectInternalList:
			formatter.printf("[")!;
			foreach (i, ol : o.array)
			{
				formatter.printf(i == 0 ? " " : ", ")!;
				ol.to_format(formatter)!;
			}
			formatter.printf(" ]")!;
		case ObjectInternalMap:
			formatter.printf("{")!;
			@pool()
			{
				foreach (i, key : o.map.key_tlist())
				{
					formatter.printf(i == 0 ? " " : ", ")!;
					formatter.printf(`"%s": `, key)!;
					o.map.get(key).to_format(formatter)!;
				}
			};
			formatter.printf(" }")!;
		default:
			switch (o.type.kindof)
			{
				case SIGNED_INT:
					formatter.printf("%d", o.i)!;
				case UNSIGNED_INT:
					formatter.printf("%d", (uint128)o.i)!;
				case FLOAT:
					formatter.printf("%d", o.f)!;
				case ENUM:
					formatter.printf("%d", o.i)!;
				default:
					formatter.printf("<>")!;
			}
	}
}

fn Object* new_obj(Allocator* using = mem::heap())
{
	Object* o = malloc(Object, .using = using);
	*o = { .allocator = using, .type = void.typeid };
	return o;
}

fn Object* new_null()
{
	return &NULL_OBJECT;
}

fn Object* new_int(int128 i, Allocator* using = mem::heap())
{
	Object* o = malloc(Object, .using = using);
	*o = { .i = i, .allocator = using, .type = int128.typeid };
	return o;
}

macro Object* new_enum(e, Allocator* using = mem::heap())
{
	Object* o = malloc(Object, .using = using);
	*o = { .i = (int128)e, .allocator = using, .type = $typeof(e).typeid };
	return o;
}

fn Object* new_float(double f, Allocator* using = mem::current_allocator())
{
	Object* o = malloc(Object, .using = using);
	*o = { .f = f, .allocator = using, .type = double.typeid };
	return o;
}

fn Object* new_string(String s, Allocator* using = mem::heap())
{
	Object* o = malloc(Object, .using = using);
	*o = { .s = s.copy(using), .allocator = using, .type = String.typeid };
	return o;
}


fn Object* new_bool(bool b)
{
	return b ? &TRUE_OBJECT : &FALSE_OBJECT;
}

/**
 * @param [&inout] o
 **/
fn void Object.free(Object* o)
{
	switch (o.type)
	{
		case void:
			break;
		case String:
			free(o.s, .using = o.allocator);
		case ObjectInternalList:
			foreach (ol : o.array)
			{
				ol.free();
			}
			o.array.free();
		case ObjectInternalMap:
			@pool()
			{
				foreach (key : o.map.key_tlist())
				{
					o.map.get(key).free();
					free(key, .using = o.allocator);
				}
				o.map.free();
			};
		default:
			break;
	}
	if (o.allocator) free(o, .using = o.allocator);
}

fn bool Object.is_null(Object* this) @inline => this == &NULL_OBJECT;
fn bool Object.is_empty(Object* this) @inline => this.type == void.typeid;
fn bool Object.is_map(Object* this) @inline => this.type == ObjectInternalMap.typeid;
fn bool Object.is_array(Object* this) @inline => this.type == ObjectInternalList.typeid;
fn bool Object.is_bool(Object* this) @inline => this.type == bool.typeid;
fn bool Object.is_string(Object* this) @inline => this.type == String.typeid;
fn bool Object.is_float(Object* this) @inline => this.type == double.typeid;
fn bool Object.is_int(Object* this) @inline => this.type == int128.typeid;
fn bool Object.is_keyable(Object* this) => this.is_empty() || this.is_map();
fn bool Object.is_indexable(Object* this) => this.is_empty() || this.is_array();

/**
 * @require o.is_keyable()
 **/
fn void Object.init_map_if_needed(Object* o) @private
{
	if (o.is_empty())
	{
		o.type = ObjectInternalMap.typeid;
		o.map.init(.using = o.allocator);
	}
}

/**
 * @require o.is_indexable()
 **/
fn void Object.init_array_if_needed(Object* o) @private
{
	if (o.is_empty())
	{
		o.type = ObjectInternalList.typeid;
		o.array.init(.using = o.allocator);
	}
}

/**
 * @require o.is_keyable()
 **/
fn void Object.set_object(Object* o, String key, Object* new_object) @private
{
	o.init_map_if_needed();
	ObjectInternalMapEntry*! entry = o.map.get_entry(key);
	defer
	{
		(void)free(entry.key, .using = o.allocator);
		entry.value.free();
	}
	o.map.set(key.copy(o.map.allocator), new_object);
}

macro Object* object_from_value(value) @private
{
	var $Type = $typeof(value);

$switch
	$case types::is_int($Type):
		return new_int(value);
	$case types::is_float($Type):
		return new_float(value);
	$case $Type.typeid == String.typeid:
		return new_string(value);
	$case $Type.typeid == bool.typeid:
		return new_bool(value);
	$case $Type.typeid == Object*.typeid:
		return value;
	$case $Type.typeid == void*.typeid:
		assert(value == null);
		return &NULL_OBJECT;
	$case $checks(String s = value):
		return new_string(value);
	$default:
		$assert(false, "Unsupported object type.");
$endswitch

}

macro Object* Object.set(Object* o, String key, value)
{
	Object* val = object_from_value(value);
	o.set_object(key, val);
	return val;
}

/**
 * @require o.is_indexable()
 **/
macro Object* Object.set_at(Object* o, usz index, String key, value)
{
	Object* val = object_from_value(value);
	o.set_object_at(key, index, val);
	return val;
}

/**
 * @require o.is_indexable()
 * @ensure return != null
 **/
macro Object* Object.append(Object* o, value)
{
	Object* val = object_from_value(value);
	o.append_object(val);
	return val;
}

/**
 * @require o.is_keyable()
 **/
fn Object*! Object.get(Object* o, String key) => o.is_empty() ? SearchResult.MISSING? : o.map.get(key);


fn bool Object.has_key(Object* o, String key) => o.is_map() && o.map.has_key(key);

/**
 * @require o.is_indexable()
 **/
fn Object* Object.get_at(Object* o, usz index)
{
	return o.array.get(index);
}

/**
 * @require o.is_indexable()
 **/
fn void Object.append_object(Object* o, Object* to_append)
{
	o.init_array_if_needed();
	o.array.append(to_append);
}

/**
 * @require o.is_indexable()
 **/
fn void Object.set_object_at(Object* o, usz index, Object* to_set)
{
	o.init_array_if_needed();
	while (o.array.len() < index)
	{
		o.array.append(&NULL_OBJECT);
	}
	if (o.array.len() == index)
	{
		o.array.append(to_set);
		return;
	}
	o.array.get(index).free();
	o.array.set_at(index, to_set);
}

macro get_integer_value(Object* value, $Type)
{
	if (value.is_float())
	{
		return ($Type)value.f;
	}
	if (value.is_string())
	{
		$if ($Type.kindof == TypeKind.SIGNED_INT)
			return ($Type)value.s.to_int128();
		$else
			return ($Type)value.s.to_uint128();
		$endif
	}
	if (!value.is_int()) return NumberConversion.MALFORMED_INTEGER?;
	return ($Type)value.i;
}

/**
 * @require o.is_indexable()
 **/
macro Object.get_integer_at(Object* o, $Type, usz index) @private
{
	return get_integer_value(o.get_at(index), $Type);
}

/**
 * @require o.is_keyable()
 **/
macro Object.get_integer(Object* o, $Type, String key) @private
{
	return get_integer_value(o.get(key), $Type);
}

fn ichar! Object.get_ichar(Object* o, String key) => o.get_integer(ichar, key);
fn short! Object.get_short(Object* o, String key) => o.get_integer(short, key);
fn int! Object.get_int(Object* o, String key) => o.get_integer(int, key);
fn long! Object.get_long(Object* o, String key) => o.get_integer(long, key);
fn int128! Object.get_int128(Object* o, String key) => o.get_integer(int128, key);

fn ichar! Object.get_ichar_at(Object* o, usz index) => o.get_integer_at(ichar, index);
fn short! Object.get_short_at(Object* o, usz index) => o.get_integer_at(short, index);
fn int! Object.get_int_at(Object* o, usz index) => o.get_integer_at(int, index);
fn long! Object.get_long_at(Object* o, usz index) => o.get_integer_at(long, index);
fn int128! Object.get_int128_at(Object* o, usz index) => o.get_integer_at(int128, index);

fn char! Object.get_char(Object* o, String key) => o.get_integer(ichar, key);
fn short! Object.get_ushort(Object* o, String key) => o.get_integer(ushort, key);
fn uint! Object.get_uint(Object* o, String key) => o.get_integer(uint, key);
fn ulong! Object.get_ulong(Object* o, String key) => o.get_integer(ulong, key);
fn uint128! Object.get_uint128(Object* o, String key) => o.get_integer(uint128, key);

fn char! Object.get_char_at(Object* o, usz index) => o.get_integer_at(char, index);
fn ushort! Object.get_ushort_at(Object* o, usz index) => o.get_integer_at(ushort, index);
fn uint! Object.get_uint_at(Object* o, usz index) => o.get_integer_at(uint, index);
fn ulong! Object.get_ulong_at(Object* o, usz index) => o.get_integer_at(ulong, index);
fn uint128! Object.get_uint128_at(Object* o, usz index) => o.get_integer_at(uint128, index);

/**
 * @require o.is_keyable()
 **/
fn String! Object.get_string(Object* o, String key)
{
	Object* value = o.get(key)!;
	assert(value.is_string());
	return value.s;
}

/**
 * @require o.is_indexable()
 **/
fn String Object.get_string_at(Object* o, usz index)
{
	Object* value = o.get_at(index);
	assert(value.is_string());
	return value.s;
}

/**
 * @require o.is_keyable()
 **/
macro String! Object.get_enum(Object* o, $EnumType, String key)
{
	Object value = o.get(key)!;
	assert($EnumType.typeid == value.type);
	return ($EnumType)value.i;
}

/**
 * @require o.is_indexable()
 **/
macro String Object.get_enum_at(Object* o, $EnumType, usz index)
{
	Object value = o.get_at(index);
	assert($EnumType.typeid == value.type);
	return ($EnumType)value.i;
}

/**
 * @require o.is_keyable()
 **/
fn bool! Object.get_bool(Object* o, String key)
{
	Object* value = o.get(key)!;
	assert(value.is_bool());
	return value.b;
}


/**
 * @require o.is_indexable()
 **/
fn bool Object.get_bool_at(Object* o, usz index)
{
	Object* value = o.get_at(index);
	assert(value.is_bool());
	return value.b;
}

/**
 * @require o.is_keyable()
 **/
fn double! Object.get_float(Object* o, String key)
{
	Object* value = o.get(key)!;
	switch (value.type.kindof)
	{
		case SIGNED_INT:
			return (double)value.i;
		case UNSIGNED_INT:
			return (double)(uint128)value.i;
		case FLOAT:
			return value.f;
		default:
			unreachable();
	}
}

/**
 * @require o.is_indexable()
 **/
fn double Object.get_float_at(Object* o, usz index)
{
	Object* value = o.get_at(index);
	switch (value.type.kindof)
	{
		case SIGNED_INT:
			return (double)value.i;
		case UNSIGNED_INT:
			return (double)(uint128)value.i;
		case FLOAT:
			return value.f;
		default:
			unreachable();
	}
}

fn Object* Object.get_or_create_obj(Object* o, String key)
{
	if (try obj = o.get(key) && !obj.is_null()) return obj;
	Object* container = new_obj();
	o.set(key, container);
	return container;
}

def ObjectInternalMap @private = HashMap<String, Object*>;
def ObjectInternalList @private = List<Object*>;
def ObjectInternalMapEntry @private = Entry<String, Object*>;

//  priorityqueue.c3
//  A priority queue using a classic binary heap for C3.
//
//  Copyright (c) 2022 David Kopec
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
module std::collections::priorityqueue<Type>;
import std::collections::list;

def Heap = List<Type>;

struct PriorityQueue
{
	Heap heap;
	bool max;  // true if max-heap, false if min-heap
}

fn void PriorityQueue.push(PriorityQueue* pq, Type element)
{
	pq.heap.push(element);
	usz i = pq.heap.len() - 1;
	while (i > 0)
	{
		usz parent = (i - 1) / 2;
		if ((pq.max && greater(pq.heap.get(i), pq.heap.get(parent))) || (!pq.max && less(pq.heap.get(i), pq.heap.get(parent))))
		{
			pq.heap.swap(i, parent);
			i = parent;
			continue;
		}
		break;
	}
}

/**
* @require pq != null
*/
fn Type! PriorityQueue.pop(PriorityQueue* pq)
{
	usz i = 0;
	usz len = pq.heap.len() @inline;
	if (!len) return IteratorResult.NO_MORE_ELEMENT?;
	usz newCount = len - 1;
	pq.heap.swap(0, newCount);
	while ((2 * i + 1) < newCount)
	{
		usz j = 2 * i + 1;
		if (((j + 1) < newCount) &&
			((pq.max && greater(pq.heap.get(j + 1), pq.heap[j]))
				|| (!pq.max && less(pq.heap.get(j + 1), pq.heap.get(j)))))
		{
			j++;
		}
		if ((pq.max && less(pq.heap.get(i), pq.heap.get(j))) || (!pq.max && greater(pq.heap.get(i), pq.heap.get(j))))
		{
			pq.heap.swap(i, j);
			i = j;
			continue;
		}
		break;
	}

	return pq.heap.pop();
}

/**
 * @require pq != null
 */
fn Type! PriorityQueue.peek(PriorityQueue* pq)
{
	if (!pq.len()) return IteratorResult.NO_MORE_ELEMENT?;
	return pq.heap.get(0);
}

/**
 * @require pq != null
 */
fn void PriorityQueue.free(PriorityQueue* pq)
{
	pq.heap.free();
}

/**
 * @require pq != null
 */
fn usz PriorityQueue.len(PriorityQueue* pq) @operator(len)
{
	return pq.heap.len();
}

/**
 * @require pq != null, index < pq.len()
 */
fn Type PriorityQueue.peek_at(PriorityQueue* pq, usz index) @operator([])
{
	return pq.heap[index];
}

// Copyright (c) 2023 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::mem::allocator;

struct ArenaAllocator
{
	inline Allocator allocator;
	char[] data;
	usz used;
}

/**
 * Initialize a memory arena for use using the provided bytes.
 *
 * @require this != null
 **/
fn void ArenaAllocator.init(ArenaAllocator* this, char[] data)
{
	this.function = &arena_allocator_function;
	this.data = data;
	this.used = 0;
}

/**
 * @require this != null
 **/
fn void ArenaAllocator.reset(ArenaAllocator* this)
{
	this.used = 0;
}

struct ArenaAllocatorHeader
{
	usz size;
	char[*] data;
}
/**
 * @require !alignment || math::is_power_of_2(alignment)
 * @require data `unexpectedly missing the allocator`
 */
fn void*! arena_allocator_function(Allocator* data, usz size, usz alignment, usz offset, void* old_pointer, AllocationKind kind) @private
{
	ArenaAllocator* arena = (ArenaAllocator*)data;
	bool clear = false;
	switch (kind)
	{
		case CALLOC:
		case ALIGNED_CALLOC:
			clear = true;
			nextcase;
		case ALLOC:
		case ALIGNED_ALLOC:
			assert(!old_pointer, "Unexpected old pointer for alloc.");
			if (!size) return null;
			alignment = alignment_for_allocation(alignment);
			void* mem = arena._alloc(size, alignment, offset)!;
			if (clear) mem::clear(mem, size, mem::DEFAULT_MEM_ALIGNMENT);
        	return mem;
		case ALIGNED_REALLOC:
		case REALLOC:
			if (!size) nextcase FREE;
			if (!old_pointer) nextcase ALLOC;
			alignment = alignment_for_allocation(alignment);
			return arena._realloc(old_pointer, size, alignment, offset)!;
		case ALIGNED_FREE:
		case FREE:
			if (!old_pointer) return null;
			assert((uptr)old_pointer >= (uptr)arena.data.ptr, "Pointer originates from a different allocator.");
			ArenaAllocatorHeader* header = old_pointer - ArenaAllocatorHeader.sizeof;
			// Reclaim memory if it's the last element.
			if (old_pointer + header.size == &arena.data[arena.used])
        	{
        		arena.used -= header.size + ArenaAllocatorHeader.sizeof;
        	}
        	return null;
        case MARK:
            return (void*)(uptr)arena.used;
		case RESET:
			arena.used = size;
			return null;
	}
	unreachable();
}

/**
 * @require alignment > 0 `alignment must be non zero`
 * @require math::is_power_of_2(alignment)
 * @require size > 0
 * @require alignment <= mem::MAX_MEMORY_ALIGNMENT `alignment too big`
 * @require offset <= mem::MAX_MEMORY_ALIGNMENT `offset too big`
 * @require offset <= size && offset >= 0
 * @require mem::aligned_offset(offset, ArenaAllocatorHeader.alignof) == offset
 * @require this != null
 **/
fn void*! ArenaAllocator._alloc(ArenaAllocator* this, usz size, usz alignment, usz offset) @private
{
	usz total_len = this.data.len;
	if (size > total_len) return AllocationFailure.CHUNK_TOO_LARGE?;
    void* start_mem = this.data.ptr;
	void* unaligned_pointer_to_offset = start_mem + this.used + ArenaAllocatorHeader.sizeof + offset;
	void* aligned_pointer_to_offset = mem::aligned_pointer(unaligned_pointer_to_offset, alignment);
	usz end = (usz)(aligned_pointer_to_offset - this.data.ptr) + size - offset;
	if (end > total_len) return AllocationFailure.OUT_OF_MEMORY?;
	this.used = end;
	void *mem = aligned_pointer_to_offset - offset;
	ArenaAllocatorHeader* header = mem - ArenaAllocatorHeader.sizeof;
	header.size = size;
	return mem;
}

/**
 * @require alignment > 0 `alignment must be non zero`
 * @require math::is_power_of_2(alignment)
 * @require size > 0
 * @require alignment <= mem::MAX_MEMORY_ALIGNMENT `alignment too big`
 * @require offset <= mem::MAX_MEMORY_ALIGNMENT `offset too big`
 * @require offset <= size && offset >= 0
 * @require mem::aligned_offset(offset, ArenaAllocatorHeader.alignof) == offset
 * @require this != null
 **/
fn void*! ArenaAllocator._realloc(ArenaAllocator* this, void *old_pointer, usz size, usz alignment, usz offset) @private
{
	assert(old_pointer >= this.data.ptr, "Pointer originates from a different allocator.");
	usz total_len = this.data.len;
	if (size > total_len) return AllocationFailure.CHUNK_TOO_LARGE?;
	ArenaAllocatorHeader* header = old_pointer - ArenaAllocatorHeader.sizeof;
	usz old_size = header.size;
	// Do last allocation and alignment match?
	if (&this.data[this.used] == old_pointer + old_size && mem::ptr_is_aligned(old_pointer + offset, alignment))
	{
		if (old_size >= size)
        {
        	this.used -= old_size - size;
        }
        else
        {
	        usz new_used = this.used + size - old_size;
            if (new_used > total_len) return AllocationFailure.OUT_OF_MEMORY?;
            this.used = new_used;
        }
        header.size = size;
        return old_pointer;
	}
	// Otherwise just allocate new memory.
	void* mem = this._alloc(size, alignment, offset)!;
	mem::copy(mem, old_pointer, old_size, mem::DEFAULT_MEM_ALIGNMENT, mem::DEFAULT_MEM_ALIGNMENT);
	return mem;
}

// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.

module std::core::mem::allocator;

struct DynamicArenaAllocator
{
	inline Allocator allocator;
	Allocator* backing_allocator;
	DynamicArenaPage* page;
	DynamicArenaPage* unused_page;
	usz page_size;
}

/**
 * @require page_size >= 128
 * @require this != null
 **/
fn void DynamicArenaAllocator.init(DynamicArenaAllocator* this, usz page_size, Allocator* backing_allocator = mem::heap())
{
	this.function = &dynamic_arena_allocator_function;
	this.page = null;
	this.unused_page = null;
	this.page_size = page_size;
	this.backing_allocator = backing_allocator;
}

/**
 * @require this != null
 **/
fn void DynamicArenaAllocator.destroy(DynamicArenaAllocator* this)
{
	DynamicArenaPage* page = this.page;
	while (page)
	{
		DynamicArenaPage* next_page = page.prev_arena;
		free(page, .using = this.backing_allocator);
		page = next_page;
	}
	page = this.unused_page;
	while (page)
	{
		DynamicArenaPage* next_page = page.prev_arena;
		free(page, .using = this.backing_allocator);
		page = next_page;
	}
	this.page = null;
	this.unused_page = null;
}

struct DynamicArenaPage
{
	void* memory;
	void* prev_arena;
	usz total;
	usz used;
	void* last_ptr;
}

struct DynamicArenaChunk @local
{
	usz size;
}

/**
 * @require ptr && this
 * @require this.page `tried to free pointer on invalid allocator`
 */
fn void DynamicArenaAllocator.free(DynamicArenaAllocator* this, void* ptr) @private
{
	DynamicArenaPage* current_page = this.page;
	if (ptr == current_page.last_ptr)
	{
		current_page.used = (usz)((ptr - DEFAULT_SIZE_PREFIX) - current_page.memory);
	}
	current_page.last_ptr = null;
}

/**
 * @require old_pointer && size > 0
 * @require this.page `tried to realloc pointer on invalid allocator`
 */
fn void*! DynamicArenaAllocator._realloc(DynamicArenaAllocator* this, void* old_pointer, usz size, usz alignment, usz offset) @local
{
	DynamicArenaPage* current_page = this.page;
	alignment = alignment_for_allocation(alignment);
	usz* old_size_ptr = old_pointer - DEFAULT_SIZE_PREFIX;
	usz old_size = *old_size_ptr;
	// We have the old pointer and it's correctly aligned.
	if (old_size >= size && mem::ptr_is_aligned(old_pointer, alignment))
	{
		*old_size_ptr = size;
		if (current_page.last_ptr == old_pointer)
		{
			current_page.used = (usz)((old_pointer - DEFAULT_SIZE_PREFIX) - current_page.memory);
		}
		return old_pointer;
	}
	if REUSE: (current_page.last_ptr == old_pointer && mem::ptr_is_aligned(old_pointer, alignment))
	{
		assert(size > old_size);
		usz add_size = size - old_size;
		if (add_size + current_page.used > current_page.total) break REUSE;
		*old_size_ptr = size;
		current_page.used += add_size;
		return old_pointer;
	}
	void* new_mem = this._alloc(size, alignment, offset)!;
	mem::copy(new_mem, old_pointer, old_size, mem::DEFAULT_MEM_ALIGNMENT);
	return new_mem;
}

fn void DynamicArenaAllocator.reset(DynamicArenaAllocator* this) @private
{
	DynamicArenaPage* page = this.page;
	DynamicArenaPage** unused_page_ptr = &this.unused_page;
    while (page)
    {
        DynamicArenaPage* next_page = page.prev_arena;
        page.used = 0;
        DynamicArenaPage* prev_unused = *unused_page_ptr;
        *unused_page_ptr = page;
        page.prev_arena = prev_unused;
        page = next_page;
    }
    this.page = page;
}

/**
 * @require math::is_power_of_2(alignment)
 * @require size > 0
 */
fn void*! DynamicArenaAllocator._alloc_new(DynamicArenaAllocator* this, usz size, usz alignment, usz offset) @local
{
	// First, make sure that we can align it, extending the page size if needed.
	usz page_size = max(this.page_size, mem::aligned_offset(size + DynamicArenaChunk.sizeof + offset, alignment) - offset);

	// Grab the page without alignment (we do it ourselves)
	void* mem = this.backing_allocator.alloc(page_size)!;
	DynamicArenaPage*! page = malloc(DynamicArenaPage, .using = this.backing_allocator);
	if (catch err = page)
	{
		free(mem, .using = this.backing_allocator);
		return err?;
	}
    page.memory = mem;
    void* mem_start = mem::aligned_pointer(mem + offset + DynamicArenaChunk.sizeof, alignment) - offset;
    assert(mem_start + size < mem + page_size);
    DynamicArenaChunk* chunk = (DynamicArenaChunk*)mem_start - 1;
    chunk.size = size;
	page.prev_arena = this.page;
	page.total = page_size;
	page.used = mem_start + size - page.memory;
	this.page = page;
	page.last_ptr = mem_start;
	return mem_start;
}

/**
 * @require !alignment || math::is_power_of_2(alignment)
 * @require size > 0
 * @require this
 */
fn void*! DynamicArenaAllocator._alloc(DynamicArenaAllocator* this, usz size, usz alignment, usz offset) @local
{
	alignment = alignment_for_allocation(alignment);
	DynamicArenaPage* page = this.page;
	if (!page && this.unused_page)
	{
		this.page = page = this.unused_page;
		this.unused_page = page.prev_arena;
		page.prev_arena = null;
	}
    if (!page) return this._alloc_new(size, alignment, offset);
    void* start = mem::aligned_pointer(page.memory + page.used + DynamicArenaChunk.sizeof + offset, alignment) - offset;
    usz new_used = start - page.memory + size;
    if ALLOCATE_NEW: (new_used > page.total)
    {
        if ((page = this.unused_page))
        {
            start = mem::aligned_pointer(page.memory + page.used + DynamicArenaChunk.sizeof + offset, alignment) - offset;
            new_used = start + size - page.memory;
            if (page.total >= new_used)
            {
	    		this.unused_page = page.prev_arena;
    	    	page.prev_arena = this.page;
    		    this.page = page;
    		    break ALLOCATE_NEW;
            }
        }
 	    return this._alloc_new(size, alignment, offset);
    }

    page.used = new_used;
	assert(start + size == page.memory + page.used);
    void* mem = start;
    DynamicArenaChunk* chunk = (DynamicArenaChunk*)mem - 1;
    chunk.size = size;
    return mem;
}

/**
 * @require !alignment || math::is_power_of_2(alignment)
 * @require data `unexpectedly missing the allocator`
 */
fn void*! dynamic_arena_allocator_function(Allocator* data, usz size, usz alignment, usz offset, void* old_pointer, AllocationKind kind) @private
{
	DynamicArenaAllocator* allocator = (DynamicArenaAllocator*)data;
	switch (kind)
	{
		case CALLOC:
		case ALIGNED_CALLOC:
			assert(!old_pointer, "Unexpected no old pointer for calloc.");
			if (!size) return null;
			void* mem = allocator._alloc(size, alignment, offset)!;
			mem::clear(mem, size, mem::DEFAULT_MEM_ALIGNMENT);
			return mem;
		case ALLOC:
		case ALIGNED_ALLOC:
			assert(!old_pointer, "Unexpected no old pointer for alloc.");
			if (!size) return null;
			return allocator._alloc(size, alignment, offset);
		case REALLOC:
		case ALIGNED_REALLOC:
			if (!size)
			{
				if (!old_pointer) return null;
				allocator.free(old_pointer);
				return null;
			}
			if (!old_pointer) return allocator._alloc(size, alignment, offset);
			void* mem = allocator._realloc(old_pointer, size, alignment, offset)!;
			return mem;
		case ALIGNED_FREE:
		case FREE:
			if (!old_pointer) return null;
			allocator.free(old_pointer);
			return null;
		case MARK:
			unreachable("Tried to mark a dynamic arena");
		case RESET:
			allocator.reset();
			return null;
	}
	unreachable();
}

// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.

module std::core::mem::allocator;

def MemoryAllocFn = fn char[]!(usz);

struct SimpleHeapAllocator
{
	inline Allocator allocator;
	MemoryAllocFn alloc_fn;
	Header* free_list;
}

/**
 * @require this "Unexpectedly missing the allocator"
 * @require allocator "An underlying memory provider must be given"
 * @require !this.free_list "The allocator may not be already initialized"
 **/
fn void SimpleHeapAllocator.init(SimpleHeapAllocator* this, MemoryAllocFn allocator)
{
	this.alloc_fn = allocator;
	this.allocator = { &simple_heap_allocator_function };
	this.free_list = null;
}

/**
 * @require !alignment || math::is_power_of_2(alignment)
 * @require this `unexpectedly missing the allocator`
 */
fn void*! simple_heap_allocator_function(Allocator* this, usz size, usz alignment, usz offset, void* old_pointer, AllocationKind kind) @private
{
	SimpleHeapAllocator* heap = (SimpleHeapAllocator*)this;
	switch (kind)
    {
        case ALIGNED_ALLOC:
            return @aligned_alloc(heap._alloc, size, alignment, offset);
		case ALLOC:
            return heap._alloc(size);
        case ALIGNED_CALLOC:
            return @aligned_calloc(heap._calloc, size, alignment, offset);
    	case CALLOC:
            return heap._calloc(size);
        case ALIGNED_REALLOC:
            if (!size) nextcase ALIGNED_FREE;
            if (!old_pointer) nextcase ALIGNED_CALLOC;
            return @aligned_realloc(heap._calloc, heap._free, old_pointer, size, alignment, offset);
        case REALLOC:
            if (!size) nextcase FREE;
            if (!old_pointer) nextcase CALLOC;
            return heap._realloc(old_pointer, size);
        case RESET:
            return AllocationFailure.UNSUPPORTED_OPERATION?;
        case ALIGNED_FREE:
            @aligned_free(heap._free, old_pointer)!;
            return null;
        case FREE:
            heap._free(old_pointer);
            return null;
        default:
            unreachable();
	}
}

/**
 * @require this && old_pointer && bytes > 0
 **/
fn void*! SimpleHeapAllocator._realloc(SimpleHeapAllocator* this, void* old_pointer, usz bytes)
{
	// Find the block header.
	Header* block = (Header*)old_pointer - 1;
	if (block.size >= bytes) return old_pointer;
	void* new = this._alloc(bytes)!;
	usz max_to_copy = math::min(block.size, bytes);
	mem::copy(new, old_pointer, max_to_copy);
	this._free(old_pointer);
	return new;
}

fn void*! SimpleHeapAllocator._calloc(SimpleHeapAllocator* this, usz bytes) @local
{
	void* data = this._alloc(bytes)!;
	mem::clear(data, bytes, mem::DEFAULT_MEM_ALIGNMENT);
	return data;
}

fn void*! SimpleHeapAllocator._alloc(SimpleHeapAllocator* this, usz bytes) @local
{
	usz aligned_bytes = mem::aligned_offset(bytes, mem::DEFAULT_MEM_ALIGNMENT);
    if (!this.free_list)
    {
		this.add_block(aligned_bytes)!;
    }

	Header* current = this.free_list;
	Header* previous = current;
	while (current)
	{
		switch
		{
			case current.size >= aligned_bytes && current.size <= aligned_bytes + Header.sizeof + 64:
				if (current == previous)
				{
					this.free_list = current.next;
				}
				else
				{
					previous.next = current.next;
                }
                current.next = null;
                return current + 1;
            case current.size > aligned_bytes:
				Header* unallocated = (Header*)((char*)current + aligned_bytes + Header.sizeof);
				unallocated.size = current.size - aligned_bytes;
				unallocated.next = current.next;
				if (current == this.free_list)
				{
					this.free_list = unallocated;
				}
				else
				{
					previous.next = unallocated;
				}
				current.size = aligned_bytes;
				current.next = null;
				return current + 1;
			default:
				previous = current;
				current = current.next;
		}
	}
	this.add_block(aligned_bytes)!;
	return this.alloc(aligned_bytes);
}

fn void! SimpleHeapAllocator.add_block(SimpleHeapAllocator* this, usz aligned_bytes) @local
{
	assert(mem::aligned_offset(aligned_bytes, mem::DEFAULT_MEM_ALIGNMENT) == aligned_bytes);
	char[] result = this.alloc_fn(aligned_bytes + Header.sizeof)!;
	Header* new_block = (Header*)result.ptr;
	new_block.size = result.len - Header.sizeof;
	new_block.next = null;
	this._free(new_block + 1);
}


fn void SimpleHeapAllocator._free(SimpleHeapAllocator* this, void* ptr) @local
{
	// Empty ptr -> do nothing.
	if (!ptr) return;

	// Find the block header.
	Header* block = (Header*)ptr - 1;

	// No free list? Then just return this.
	if (!this.free_list)
	{
		this.free_list = block;
		return;
	}

	// Find where in the list it should be inserted.
	Header* current = this.free_list;
	Header* prev = current;
	while (current)
	{
		if (block < current)
		{
			// Between prev and current
			if (block > prev) break;
			// Before current
			if (current == prev) break;
		}
		prev = current;
		current = prev.next;
	}
	if (current)
	{
		// Insert after the current block.
        // Are the blocks adjacent?
        if (current == (Header*)((char*)(block + 1) + block.size))
        {
            // Merge
    		block.size += current.size + Header.sizeof;
            block.next = current.next;
        }
        else
        {
            // Chain to current
            block.next = current;
        }
	}
	if (prev == current)
	{
		// Swap new start of free list
		this.free_list = block;
	}
	else
	{
		// Prev adjacent?
		if (block == (Header*)((char*)(prev + 1) + prev.size))
		{
    		prev.size += block.size + Header.sizeof;
			prev.next = block.next;
		}
		else
		{
	        // Link prev to block
	        prev.next = block;
		}
	}
}

union Header @private
{
	struct
	{
		Header* next;
  	    usz size;
    }
    usz align;
}
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.

module std::core::mem::allocator;
import libc;

const Allocator _NULL_ALLOCATOR @private = { &null_allocator_fn };
const Allocator _SYSTEM_ALLOCATOR @private = { &libc_allocator_fn };

fn void*! null_allocator_fn(Allocator* this, usz bytes, usz alignment, usz offset, void* old_pointer, AllocationKind kind) @private
{
	switch (kind)
	{
		case ALLOC:
        case CALLOC:
        case REALLOC:
        case ALIGNED_ALLOC:
        case ALIGNED_REALLOC:
        case ALIGNED_CALLOC:
			return AllocationFailure.OUT_OF_MEMORY?;
		default:
			return null;
	}
}

struct AlignedBlock
{
	usz len;
	void* start;
}

/**
 * @require bytes > 0
 * @require alignment > 0
 **/
macro void*! @aligned_alloc(#alloc_fn, usz bytes, usz alignment, usz offset)
{
	usz header = mem::aligned_offset(AlignedBlock.sizeof + offset, alignment) - offset;
	$if ($checks(#alloc_fn(bytes)!))
		void* data = #alloc_fn(header + bytes)!;
	$else
		void* data = #alloc_fn(header + bytes);
	$endif
    void* mem = mem::aligned_pointer(data + header + offset, alignment) - offset;
	assert(mem > data);
	AlignedBlock* desc = (AlignedBlock*)mem - 1;
	*desc = { bytes, data };
	return mem;
}

/**
 * @require bytes > 0
 * @require alignment > 0
 **/
macro void*! @aligned_calloc(#calloc_fn, usz bytes, usz alignment, usz offset)
{
	usz header = mem::aligned_offset(AlignedBlock.sizeof + offset, alignment) - offset;
	$if ($checks(#calloc_fn(bytes)!))
		void* data = #calloc_fn(header + bytes)!;
	$else
		void* data = #calloc_fn(header + bytes);
	$endif
	void* mem = mem::aligned_pointer(data + header + offset, alignment) - offset;
	AlignedBlock* desc = (AlignedBlock*)mem - 1;
	assert(mem > data);
	*desc = { bytes, data };
	return mem;
}

/**
 * @require bytes > 0
 * @require alignment > 0
 **/
macro void*! @aligned_realloc(#calloc_fn, #free_fn, void* old_pointer, usz bytes, usz alignment, usz offset)
{
	AlignedBlock* desc = (AlignedBlock*)old_pointer - 1;
	void* data_start = desc.start;
    void* new_data = @aligned_calloc(#calloc_fn, bytes, alignment, offset)!;
	mem::copy(new_data, old_pointer, desc.len > bytes ? desc.len : bytes, mem::DEFAULT_MEM_ALIGNMENT, mem::DEFAULT_MEM_ALIGNMENT);
	$if ($checks(#free_fn(data_start)!))
	#free_fn(data_start)!;
	$else
	#free_fn(data_start);
	$endif
	return new_data;
}

macro void! @aligned_free(#free_fn, void* old_pointer)
{
	AlignedBlock* desc = (AlignedBlock*)old_pointer - 1;
	$if ($checks(#free_fn(desc.start)!))
	#free_fn(desc.start)!;
	$else
	#free_fn(desc.start);
	$endif
}

fn void*! libc_allocator_fn(Allocator* unused, usz bytes, usz alignment, usz offset, void* old_pointer, AllocationKind kind) @inline
{
	if (!alignment) alignment = mem::DEFAULT_MEM_ALIGNMENT;
	assert(math::is_power_of_2(alignment), "Alignment was not a power of 2");

    void* data;
    switch (kind)
    {
        case ALIGNED_ALLOC:
            data = @aligned_alloc(libc::malloc, bytes, alignment, offset)!!;
        case ALLOC:
            data = libc::malloc(bytes);
        case ALIGNED_CALLOC:
            data = @aligned_calloc(fn void*(usz bytes) => libc::calloc(bytes, 1), bytes, alignment, offset)!!;
		case CALLOC:
            data = libc::calloc(bytes, 1);
        case ALIGNED_REALLOC:
            if (!bytes) nextcase ALIGNED_FREE;
            if (!old_pointer) nextcase ALIGNED_CALLOC;
            data = @aligned_realloc(fn void*(usz bytes) => libc::calloc(bytes, 1), libc::free, old_pointer, bytes, alignment, offset)!!;
        case REALLOC:
            if (!bytes) nextcase FREE;
            if (!old_pointer) nextcase CALLOC;
            data = libc::realloc(old_pointer, bytes);
        case RESET:
            return AllocationFailure.UNSUPPORTED_OPERATION?;
        case ALIGNED_FREE:
            @aligned_free(libc::free, old_pointer)!!;
            return null;
        case FREE:
            libc::free(old_pointer);
            return null;
        default:
            unreachable();
    }
    if (!data) return AllocationFailure.OUT_OF_MEMORY?;
    return data;
}
module std::core::mem::allocator;

struct OnStackAllocator
{
	inline Allocator allocator;
	Allocator* backing_allocator;
	char[] data;
	usz used;
	OnStackAllocatorExtraChunk* chunk;
}

macro void @stack_mem(usz $size; @body(Allocator* mem)) @builtin
{
	char[$size] buffer;
	OnStackAllocator allocator;
	allocator.init(&buffer, mem::heap());
	defer allocator.free();
	@body(&allocator);
}

macro void @stack_pool(usz $size; @body) @builtin
{
	char[$size] buffer;
	OnStackAllocator allocator;
	allocator.init(&buffer, mem::heap());
	defer allocator.free();
	mem::@scoped(&allocator)
	{
		@body();
	};
}

struct OnStackAllocatorExtraChunk @local
{
	bool is_aligned;
	OnStackAllocatorExtraChunk* prev;
	void* data;
}

/**
 * Initialize a memory arena for use using the provided bytes.
 *
 * @require this != null
 **/
fn void OnStackAllocator.init(OnStackAllocator* this, char[] data, Allocator* using = mem::heap())
{
	this.function = &on_stack_allocator_function;
	this.data = data;
	this.backing_allocator = using;
	this.used = 0;
}

/**
 * @require this != null
 **/
fn void OnStackAllocator.free(OnStackAllocator* this)
{
	OnStackAllocatorExtraChunk* chunk = this.chunk;
	while (chunk)
	{
		if (chunk.is_aligned)
		{
			this.backing_allocator.free_aligned(chunk.data)!!;
		}
		else
		{
			this.backing_allocator.free(chunk.data)!!;
		}
		void* old = chunk;
		chunk = chunk.prev;
		this.backing_allocator.free(old)!!;
	}
	this.chunk = null;
	this.used = 0;
}

struct OnStackAllocatorHeader
{
	usz size;
	char[*] data;
}

/**
 * @require !alignment || math::is_power_of_2(alignment)
 * @require data `unexpectedly missing the allocator`
 */
fn void*! on_stack_allocator_function(Allocator* data, usz size, usz alignment, usz offset, void* old_pointer, AllocationKind kind) @private
{
	OnStackAllocator* allocator = (OnStackAllocator*)data;
	bool clear = false;
	switch (kind)
	{
		case CALLOC:
		case ALIGNED_CALLOC:
			clear = true;
			nextcase;
		case ALLOC:
		case ALIGNED_ALLOC:
			assert(!old_pointer, "Unexpected old pointer for alloc.");
			if (!size) return null;
			return on_stack_allocator_alloc(allocator, size, alignment, offset, clear, kind == AllocationKind.ALIGNED_ALLOC || kind == AllocationKind.ALIGNED_CALLOC);
		case ALIGNED_REALLOC:
		case REALLOC:
			if (!size) nextcase FREE;
			if (!old_pointer) nextcase ALLOC;
			return on_stack_allocator_realloc(allocator, old_pointer, size, alignment, offset, kind == AllocationKind.ALIGNED_REALLOC);
		case ALIGNED_FREE:
		case FREE:
			if (!old_pointer) return null;
			if (allocation_in_stack_mem(allocator, old_pointer)) return null;
			on_stack_allocator_remove_chunk(allocator, old_pointer);
			if (kind == AllocationKind.ALIGNED_FREE)
			{
				allocator.backing_allocator.free_aligned(old_pointer)!;
			}
			else
			{
				allocator.backing_allocator.free(old_pointer)!;
			}
        	return null;
        case MARK:
		case RESET:
			return AllocationFailure.UNSUPPORTED_OPERATION?;
	}
	unreachable();
}

fn bool allocation_in_stack_mem(OnStackAllocator* a, void* ptr) @local
{
	return ptr >= a.data.ptr && ptr <= &a.data[^1];
}

fn void on_stack_allocator_remove_chunk(OnStackAllocator* a, void* ptr) @local
{
	OnStackAllocatorExtraChunk* chunk = a.chunk;
	OnStackAllocatorExtraChunk** addr = &a.chunk;
	while (chunk)
	{
		if (chunk.data == ptr)
		{
			*addr = chunk.prev;
			a.backing_allocator.free(chunk)!!;
			return;
		}
		addr = &chunk.prev;
		chunk = *addr;
	}
	unreachable("Missing chunk");
}

fn OnStackAllocatorExtraChunk* on_stack_allocator_find_chunk(OnStackAllocator* a, void* ptr) @local
{
	OnStackAllocatorExtraChunk* chunk = a.chunk;
	while (chunk)
	{
		if (chunk.data == ptr) return chunk;
		chunk = chunk.prev;
	}
	return null;
}

/**
 * @require size > 0
 * @require alignment <= mem::MAX_MEMORY_ALIGNMENT `alignment too big`
 * @require offset <= mem::MAX_MEMORY_ALIGNMENT `offset too big`
 * @require offset <= size && offset >= 0
 * @require mem::aligned_offset(offset, ArenaAllocatorHeader.alignof) == offset
 * @require a != null
 **/
fn void*! on_stack_allocator_realloc(OnStackAllocator* a, void* old_pointer, usz size, usz alignment, usz offset, bool aligned) @local @inline
{
	if (!allocation_in_stack_mem(a, old_pointer))
	{
		OnStackAllocatorExtraChunk* chunk = on_stack_allocator_find_chunk(a, old_pointer);
		assert(chunk, "Tried to realloc pointer not belonging to the allocator");
		if (aligned)
		{
			return chunk.data = a.backing_allocator.realloc_aligned(old_pointer, size, alignment, offset)!;
		}
		return chunk.data = a.backing_allocator.realloc(old_pointer, size)!;
	}

	OnStackAllocatorHeader* header = old_pointer - OnStackAllocatorHeader.sizeof;
	usz old_size = header.size;
	void* mem = on_stack_allocator_alloc(a, size, alignment, offset, true, aligned)!;
	mem::copy(mem, old_pointer, old_size, mem::DEFAULT_MEM_ALIGNMENT, mem::DEFAULT_MEM_ALIGNMENT);
	return mem;
}

import std::io;
/**
 * @require size > 0
 * @require alignment <= mem::MAX_MEMORY_ALIGNMENT `alignment too big`
 * @require offset <= mem::MAX_MEMORY_ALIGNMENT `offset too big`
 * @require offset <= size && offset >= 0
 * @require mem::aligned_offset(offset, ArenaAllocatorHeader.alignof) == offset
 * @require a != null
 **/
fn void*! on_stack_allocator_alloc(OnStackAllocator* a, usz size, usz alignment, usz offset, bool clear, bool aligned) @local @inline
{
	alignment = alignment_for_allocation(alignment);
	usz total_len = a.data.len;
    void* start_mem = a.data.ptr;
	void* unaligned_pointer_to_offset = start_mem + a.used + OnStackAllocatorHeader.sizeof + offset;
	void* aligned_pointer_to_offset = mem::aligned_pointer(unaligned_pointer_to_offset, alignment);
	usz end = (usz)(aligned_pointer_to_offset - a.data.ptr) + size - offset;

	Allocator* backing_allocator = a.backing_allocator;

	if (end > total_len)
	{
		OnStackAllocatorExtraChunk* chunk = backing_allocator.alloc(OnStackAllocatorExtraChunk.sizeof)!;
		defer catch backing_allocator.free(chunk)!!;
		defer try a.chunk = chunk;
		*chunk = { .prev = a.chunk, .is_aligned = aligned };
		void* data @noinit;
		switch
		{
			case !aligned && !clear:
				data = backing_allocator.alloc(size)!;
			case aligned && !clear:
				data = backing_allocator.alloc_aligned(size, alignment, offset)!;
			case !aligned && clear:
				data = backing_allocator.calloc(size)!;
			case aligned && clear:
				data = backing_allocator.calloc_aligned(size, alignment, offset)!;
		}
		return chunk.data = data;
	}
	a.used = end;
	void *mem = aligned_pointer_to_offset - offset;
	OnStackAllocatorHeader* header = mem - OnStackAllocatorHeader.sizeof;
	header.size = size;
	return mem;
}
module std::core::mem::allocator;
import std::io;

struct TempAllocatorChunk @local
{
	usz size;
	char[*] data;
}

struct TempAllocator
{
	inline Allocator allocator;
	Allocator* backing_allocator;
	TempAllocatorPage* last_page;
	usz used;
	usz capacity;
	char[*] data;
}


const usz PAGE_IS_ALIGNED @private = (usz)isz.max + 1u;


struct TempAllocatorPage
{
	TempAllocatorPage* prev_page;
	void* start;
	usz mark;
	usz size;
	usz ident;
	char[*] data;
}

macro usz TempAllocatorPage.pagesize(TempAllocatorPage* page) => page.size & ~PAGE_IS_ALIGNED;
macro bool TempAllocatorPage.is_aligned(TempAllocatorPage* page) => page.size & PAGE_IS_ALIGNED == PAGE_IS_ALIGNED;

/**
 * @require size >= 16
 **/
fn TempAllocator*! new_temp(usz size, Allocator* backing_allocator)
{
	TempAllocator* allocator = malloc_checked(TempAllocator, .using = backing_allocator, .end_padding = size)!;
	allocator.last_page = null;
	allocator.function = &temp_allocator_function;
	allocator.backing_allocator = backing_allocator;
	allocator.used = 0;
	allocator.capacity = size;
	return allocator;
}

/**
 * @require !alignment || math::is_power_of_2(alignment)
 * @require data `unexpectedly missing the allocator`
 */
fn void*! temp_allocator_function(Allocator* data, usz size, usz alignment, usz offset, void* old_pointer, AllocationKind kind) @private
{
	TempAllocator* arena = (TempAllocator*)data;
	switch (kind)
	{
		case CALLOC:
		case ALIGNED_CALLOC:
			assert(!old_pointer, "Unexpected old pointer for alloc.");
			if (!size) return null;
			return arena._alloc(size, alignment_for_allocation(alignment), offset, true);
		case ALLOC:
		case ALIGNED_ALLOC:
			assert(!old_pointer, "Unexpected old pointer for alloc.");
			if (!size) return null;
			return arena._alloc(size, alignment_for_allocation(alignment), offset, false);
		case ALIGNED_REALLOC:
		case REALLOC:
			if (!size) nextcase FREE;
			if (!old_pointer) nextcase ALLOC;
			return arena._realloc(old_pointer, size, alignment_for_allocation(alignment), offset);
		case FREE:
		case ALIGNED_FREE:
			if (!old_pointer) return null;
			arena._free(old_pointer)!;
        	return null;
        case MARK:
            return (void*)(uptr)arena.used;
		case RESET:
			arena._reset(size)!;
			return null;
	}
	unreachable();
}

fn void! TempAllocator._free(TempAllocator* this, void* old_pointer) @local
{
	// TODO fix free
	assert((uptr)old_pointer >= (uptr)&this.data, "Pointer originates from a different allocator.");
	usz old_size = *(usz*)(old_pointer - DEFAULT_SIZE_PREFIX);
	if (old_pointer + old_size == &this.data[this.used])
    {
        this.used -= old_size;
    }
}
fn void! TempAllocator._reset(TempAllocator* this, usz mark) @local
{
	TempAllocatorPage *last_page = this.last_page;
	while (last_page && last_page.mark > mark)
	{
		TempAllocatorPage *to_free = last_page;
		last_page = last_page.prev_page;
		this._free_page(to_free)!;
	}
	this.last_page = last_page;
	this.used = mark;
}

fn void! TempAllocator._free_page(TempAllocator* this, TempAllocatorPage* page) @inline @local
{
	void* mem = page.start;
	if (page.is_aligned()) return this.backing_allocator.free_aligned(mem);
	return this.backing_allocator.free(mem);
}

fn void*! TempAllocator._realloc_page(TempAllocator* this, TempAllocatorPage* page, usz size, usz alignment, usz offset) @inline @local
{
	// Then the actual start pointer:
	void* real_pointer = page.start;

	// Walk backwards to find the pointer to this page.
	TempAllocatorPage **pointer_to_prev = &this.last_page;
	// Remove the page from the list
	while (*pointer_to_prev != page)
	{
		pointer_to_prev = &((*pointer_to_prev).prev_page);
	}
	*pointer_to_prev = page.prev_page;
	usz page_size = page.pagesize();
	// Clear on size > original size.
	void* data = this._alloc(size, alignment, offset, false)!;
	mem::copy(data, &page.data[0], page_size, mem::DEFAULT_MEM_ALIGNMENT, mem::DEFAULT_MEM_ALIGNMENT);
	if (page.is_aligned())
	{
		this.backing_allocator.free_aligned(real_pointer)!;
	}
	else
	{
		this.backing_allocator.free(real_pointer)!;
	}
	return data;
}

fn void*! TempAllocator._realloc(TempAllocator* this, void* pointer, usz size, usz alignment, usz offset) @inline @local
{
	TempAllocatorChunk *chunk = pointer - TempAllocatorChunk.sizeof;
	if (chunk.size == (usz)-1)
	{
		assert(this.last_page, "Realloc of non temp pointer");
		// First grab the page
		TempAllocatorPage *page = pointer - TempAllocatorPage.sizeof;
		return this._realloc_page(page, size, alignment, offset);
	}

	// TODO optimize last allocation
	TempAllocatorChunk* data = this._alloc(size, alignment, offset, size > chunk.size)!;
	mem::copy(data, pointer, chunk.size, mem::DEFAULT_MEM_ALIGNMENT, mem::DEFAULT_MEM_ALIGNMENT);

	return data;
}

/**
 * @require math::is_power_of_2(alignment)
 * @require size > 0
 * @require alignment <= mem::MAX_MEMORY_ALIGNMENT `alignment too big`
 * @require this != null
 **/
fn void*! TempAllocator._alloc(TempAllocator* this, usz size, usz alignment, usz offset, bool clear) @local
{
	void* start_mem = &this.data;
	void* starting_ptr = start_mem + this.used;
	void* aligned_header_start = mem::aligned_pointer(starting_ptr, TempAllocatorChunk.alignof);
	void* mem = aligned_header_start + TempAllocatorChunk.sizeof;
	if (alignment > TempAllocatorChunk.alignof)
	{
		mem = mem::aligned_pointer(mem + offset, alignment) - offset;
	}
	usz new_usage = (usz)(mem - start_mem) + size;

	// Arena alignment, simple!
	if (new_usage <= this.capacity)
	{
		TempAllocatorChunk* chunk_start = mem - TempAllocatorChunk.sizeof;
    	chunk_start.size = size;
    	this.used = new_usage;
    	if (clear) mem::clear(mem, size, mem::DEFAULT_MEM_ALIGNMENT);
    	return mem;
	}

	// Fallback to backing allocator
	TempAllocatorPage* page;

	// We have something we need to align.
	if (alignment > mem::DEFAULT_MEM_ALIGNMENT || offset)
	{
		// This is actually simpler, since it will create the offset for us.
		usz total_alloc_size = TempAllocatorPage.sizeof + size;
    	if (clear)
		{
			page = this.backing_allocator.calloc_aligned(total_alloc_size, alignment, TempAllocatorPage.sizeof + offset)!;
		}
		else
		{
			page = this.backing_allocator.alloc_aligned(total_alloc_size, alignment, TempAllocatorPage.sizeof + offset)!;
		}
		page.start = page;
		page.size = size | PAGE_IS_ALIGNED;
	}
	else
	{
		// Here we might need to pad
		usz padded_header_size = mem::aligned_offset(TempAllocatorPage.sizeof, mem::DEFAULT_MEM_ALIGNMENT);
		usz total_alloc_size = padded_header_size + size;
		void* alloc = (clear ? this.backing_allocator.calloc(total_alloc_size) : this.backing_allocator.alloc(total_alloc_size))!;

		// Find the page.
		page = alloc + padded_header_size - TempAllocatorPage.sizeof;
		assert(mem::ptr_is_aligned(page, TempAllocator.alignof));
		assert(mem::ptr_is_aligned(&page.data[0], mem::DEFAULT_MEM_ALIGNMENT));
		page.start = alloc;
		page.size = size;
	}

	// Mark it as a page
	page.ident = ~(usz)0;
	// Store when it was created
	page.mark = ++this.used;
	// Hook up the page.
	page.prev_page = this.last_page;
	this.last_page = page;
	return &page.data[0];
}

fn void TempAllocator.print_pages(TempAllocator* this, File f)
{
	TempAllocatorPage *last_page = this.last_page;
	if (!last_page)
	{
		f.printf("No pages.\n");
		return;
	}
	f.printf("---Pages----\n");
	uint index = 0;
	while (last_page)
	{
		bool is_not_aligned = !(last_page.size & (1u64 << 63));
		f.printf("%d. Alloc: %d %d at %p%s\n", ++index,
				last_page.size & ~(1u64 << 63), last_page.mark, &last_page.data[0], is_not_aligned ? "" : " [aligned]");
		last_page = last_page.prev_page;
	}
}
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.

module std::core::mem::allocator;
import std::collections::map;

def PtrMap = HashMap<uptr, usz>;

// A simple tracking allocator.
// It tracks allocations using a hash map but
// is not compatible with allocators that uses mark()
struct TrackingAllocator
{
	inline Allocator allocator;
	Allocator* inner_allocator;
	PtrMap map;
	usz mem_total;
	usz allocs_total;
}

/**
 * Initialize a memory arena for use using the provided bytes.
 *
 * @require this != null
 **/
fn void TrackingAllocator.init(TrackingAllocator* this, Allocator* allocator)
{
	*this = { .inner_allocator = allocator, .allocator.function = &tracking_allocator_fn };
	this.map.init(.using = allocator);
}

fn void TrackingAllocator.free(TrackingAllocator* this)
{
	this.map.free();
	*this = {};
}

/**
 * @param [inout] data
 * @require !alignment || math::is_power_of_2(alignment)
 */
fn void*! tracking_allocator_fn(Allocator* data, usz size, usz alignment, usz offset, void* old_pointer, AllocationKind kind) @private
{
	TrackingAllocator* this = (TrackingAllocator*)data;
	void* result = this.inner_allocator.function(this.inner_allocator, size, alignment, offset, old_pointer, kind)!;
	switch (kind)
	{
		case CALLOC:
		case ALIGNED_CALLOC:
		case ALLOC:
		case ALIGNED_ALLOC:
			this.map.set((uptr)result, size);
			this.mem_total += size;
			this.allocs_total++;
			return result;
		case REALLOC:
		case ALIGNED_REALLOC:
			this.map.remove((uptr)old_pointer);
			this.map.set((uptr)result, size);
			this.mem_total += size;
			if (size > 0) this.allocs_total++;
			return result;
		case ALIGNED_FREE:
		case FREE:
			if (!old_pointer) return null;
			this.map.remove((uptr)old_pointer);
			return null;
		case MARK:
			// Unsupported
			return null;
		case RESET:
			this.map.clear();
			return null;
	}
	unreachable();
}

fn usz TrackingAllocator.allocated(TrackingAllocator* this)
{
	usz allocated = 0;
	@pool()
	{
		foreach (usz allocation : this.map.value_tlist())
		{
			allocated += allocation;
		}
	};
	return allocated;
}

fn usz TrackingAllocator.total_allocated(TrackingAllocator* this)
{
	return this.mem_total;
}

fn usz TrackingAllocator.total_allocation_count(TrackingAllocator* this)
{
	return this.allocs_total;
}

fn usz TrackingAllocator.allocation_count(TrackingAllocator* this)
{
	return this.map.count;
}
module std::core::mem::allocator;


const usz WASM_BLOCK_SIZE = 65536;

WasmMemory wasm_memory;

struct WasmMemory
{
	usz allocation;
	uptr use;
}

fn char[]! WasmMemory.allocate_block(WasmMemory* this, usz bytes)
{
	if (!this.allocation)
	{
		this.allocation = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
	}
	isz bytes_required = bytes + this.use - this.allocation;
    if (bytes_required <= 0)
	{
		defer this.use += bytes;
		return ((char*)this.use)[:bytes];
	}

	usz blocks_required = (bytes_required + WASM_BLOCK_SIZE + 1) / WASM_BLOCK_SIZE;
	if ($$wasm_memory_grow(0, blocks_required) == -1) return AllocationFailure.OUT_OF_MEMORY?;
	this.allocation = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
	defer this.use += bytes;
	return ((char*)this.use)[:bytes];
}
module std::core::main_stub;

macro usz _strlen(ptr) @private
{
	usz len = 0;
	while (ptr[len]) len++;
	return len;
}

macro int @main_to_err_main(#m, int, char**)
{
	if (catch #m()) return 1;
	return 0;
}
macro int @main_to_int_main(#m, int, char**) => #m();
macro int @main_to_void_main(#m, int, char**)
{
	#m();
	return 0;
}

macro String[] args_to_strings(int argc, char** argv) @private
{
	String[] list = malloc(String, argc);
	for (int i = 0; i < argc; i++)
	{
		char* arg = argv[i];
		usz len = 0;
		list[i] = (String)arg[:_strlen(arg)];
	}
	return list;
}


macro int @main_to_err_main_args(#m, int argc, char** argv)
{
	String[] list = args_to_strings(argc, argv);
	defer free(list.ptr);
	if (catch #m(list)) return 1;
	return 0;
}

macro int @main_to_int_main_args(#m, int argc, char** argv)
{
	String[] list = args_to_strings(argc, argv);
	defer free(list.ptr);
	return #m(list);
}

macro int @main_to_void_main_args(#m, int argc, char** argv)
{
	String[] list = args_to_strings(argc, argv);
	defer free(list.ptr);
	#m(list);
	return 0;
}

$if (env::os_is_win32())

extern fn Char16** _win_command_line_to_argv_w(ushort* cmd_line, int* argc_ptr) @extern("CommandLineToArgvW");

macro String[] win_command_line_to_strings(ushort* cmd_line) @private
{
	int argc;
	Char16** argv = _win_command_line_to_argv_w(cmd_line, &argc);
	return wargs_strings(argc, argv);
}

macro String[] wargs_strings(int argc, Char16** argv) @private
{
	String[] list = malloc(String, argc);
	for (int i = 0; i < argc; i++)
	{
		Char16* arg = argv[i];
		Char16[] argstring = arg[:_strlen(arg)];
		list[i] = string::from_utf16(argstring) ?? "?".copy();
	}
	return list[:argc];
}

macro void release_wargs(String[] list) @private
{
	foreach (s : list) free(s.ptr);
	free(list.ptr);
}

macro int @win_to_err_main_noargs(#m, void* handle, Char16* cmd_line, int show_cmd)
{
	if (catch #m()) return 1;
	return 0;
}
macro int @win_to_int_main_noargs(#m, void* handle, Char16* cmd_line, int show_cmd) => #m();
macro int @win_to_void_main_noargs(#m, void* handle, Char16* cmd_line, int show_cmd)
{
	#m();
	return 0;
}

macro int @win_to_err_main_args(#m, void* handle, Char16* cmd_line, int show_cmd)
{
	String[] args = win_command_line_to_strings(cmd_line);
	defer release_wargs(args);
	if (catch #m(args)) return 1;
    return 0;
}

macro int @win_to_int_main_args(#m, void* handle, Char16* cmd_line, int show_cmd)
{
	String[] args = win_command_line_to_strings(cmd_line);
	defer release_wargs(args);
    return #m(args);
}

macro int @win_to_void_main_args(#m, void* handle, Char16* cmd_line, int show_cmd)
{
	String[] args = win_command_line_to_strings(cmd_line);
	defer release_wargs(args);
	#m(args);
	return 0;
}

macro int @win_to_err_main(#m, void* handle, Char16* cmd_line, int show_cmd)
{
	String[] args = win_command_line_to_strings(cmd_line);
	defer release_wargs(args);
	if (catch #m(handle, args, show_cmd)) return 1;
    return 0;
}

macro int @win_to_int_main(#m, void* handle, Char16* cmd_line, int show_cmd)
{
	String[] args = win_command_line_to_strings(cmd_line);
	defer release_wargs(args);
    return #m(handle, args, show_cmd);
}

macro int @win_to_void_main(#m, void* handle, Char16* cmd_line, int show_cmd)
{
	String[] args = win_command_line_to_strings(cmd_line);
	defer release_wargs(args);
	#m(handle, args, show_cmd);
	return 0;
}

macro int @wmain_to_err_main_args(#m, int argc, Char16** argv)
{
	String[] args = wargs_strings(argc, argv);
	defer release_wargs(args);
	if (catch #m(args)) return 1;
	return 1;
}

macro int @wmain_to_int_main_args(#m, int argc, Char16** argv)
{
	String[] args = wargs_strings(argc, argv);
	defer release_wargs(args);
    return #m(args);
}

macro int @wmain_to_void_main_args(#m, int argc, Char16** argv)
{
	String[] args = wargs_strings(argc, argv);
	defer release_wargs(args);
	#m(args);
	return 0;
}

$endif
module std::core::array;

/**
 * @param [in] array
 * @param [in] element
 * @return "the first index of the element"
 * @return! SearchResult.MISSING
 **/
macro index_of(array, element)
{
	foreach (i, &e : array)
	{
		if (*e == element) return i;
	}
	return SearchResult.MISSING?;
}

/**
 * @param [in] array
 * @param [in] element
 * @return "the last index of the element"
 * @return! SearchResult.MISSING
 **/
macro rindex_of(array, element)
{
	foreach_r (i, &e : array)
	{
		if (*e == element) return i;
	}
	return SearchResult.MISSING?;
}

/**
 * Concatenate two arrays or subarrays, returning a subarray containing the concatenation of them.
 *
 * @param [in] arr1
 * @param [in] arr2
 * @param [&inout] using "The allocator to use, default is the heap allocator"
 * @require @typekind(arr1) == SUBARRAY || @typekind(arr1) == ARRAY
 * @require @typekind(arr2) == SUBARRAY || @typekind(arr2) == ARRAY
 * @require @typeis(arr1[0], $typeof(arr2[0])) "Arrays must have the same type"
 * @ensure result.len == arr1.len + arr2.len
 **/
macro concat(arr1, arr2, Allocator* using = mem::heap())
{
	var $Type = $typeof(arr1[0]);
	$Type[] result = malloc($Type, arr1.len + arr2.len, .using = using);
	if (arr1.len > 0)
	{
		mem::copy(result.ptr, &arr1[0], arr1.len * $Type.sizeof, $Type.alignof, $Type.alignof);
	}
	if (arr2.len > 0)
	{
		mem::copy(&result[arr1.len], &arr2[0], arr2.len * $Type.sizeof, $Type.alignof, $Type.alignof);
	}
	return result;
}

/**
 * Concatenate two arrays or subarrays, returning a subarray containing the concatenation of them,
 * allocated using the temp allocator.
 *
 * @param [in] arr1
 * @param [in] arr2
 * @require @typekind(arr1) == SUBARRAY || @typekind(arr1) == ARRAY
 * @require @typekind(arr2) == SUBARRAY || @typekind(arr2) == ARRAY
 * @require @typeis(arr1[0], $typeof(arr2[0])) "Arrays must have the same type"
 * @ensure result.len == arr1.len + arr2.len
 **/
macro tconcat(arr1, arr2) => concat(arr1, arr2, mem::temp());
// Copyright (c) 2023 Christoffer Lerno and contributors. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::bitorder;

// This module contains types of different endianness.
// *BE types represent big-endian types
// *LE types represent little-endian types.

bitstruct ShortBE : short @bigendian
{
	short val : 0..15;
}

bitstruct UShortBE : ushort @bigendian
{
	ushort val : 0..15;
}

bitstruct IntBE : int @bigendian
{
	int val : 0..31;
}

bitstruct UIntBE : int @bigendian
{
	uint val : 0..31;
}

bitstruct LongBE : long @bigendian
{
	long val : 0..63;
}

bitstruct ULongBE : ulong @bigendian
{
	ulong val : 0..63;
}

bitstruct Int128BE : int128 @bigendian
{
	int128 val : 0..127;
}

bitstruct UInt128BE : uint128 @bigendian
{
	uint128 val : 0..127;
}

bitstruct ShortLE : short @littleendian
{
	short val : 0..15;
}

bitstruct UShortLE : ushort @littleendian
{
	ushort val : 0..15;
}

bitstruct IntLE : int @littleendian
{
	int val : 0..31;
}

bitstruct UIntLE : int @littleendian
{
	uint val : 0..31;
}

bitstruct LongLE : long @littleendian
{
	long val : 0..63;
}

bitstruct ULongLE : ulong @littleendian
{
	ulong val : 0..63;
}

bitstruct Int128LE : int128 @littleendian
{
	int128 val : 0..127;
}

bitstruct UInt128LE : uint128 @littleendian
{
	uint128 val : 0..127;
}
// Copyright (c) 2021-2022 Christoffer Lerno and contributors. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::builtin;
import libc;
import std::hash;

/**
 * Use `IteratorResult` when reading the end of an iterator, or accessing a result out of bounds.
 **/
fault IteratorResult
{
	NO_MORE_ELEMENT
}

/**
 * Use `SearchResult` when trying to return a value from some collection but the element is missing.
 **/
fault SearchResult
{
	MISSING
}

/**
 * Use `CastResult` when an attempt at conversion fails.
 **/
fault CastResult
{
	TYPE_MISMATCH
}

/**
 * Stores a variable on the stack, then restores it at the end of the
 * macro scope.
 *
 * @param variable `the variable to store and restore`
 **/
macro void @scope(&variable; @body) @builtin
{
	var temp = variable;
	defer variable = temp;
	@body();
}

/**
 * Swap two variables
 **/
macro void @swap(&a, &b) @builtin
{
	var temp = a;
	a = b;
	b = temp;
}

/**
 * Convert an `any` type to a type, returning an failure if there is a type mismatch.
 *
 * @param v `the any to convert to the given type.`
 * @param $Type `the type to convert to`
 * @return `The any.ptr converted to its type.`
 * @ensure @typeis(return, $Type*)
 * @return! CastResult.TYPE_MISMATCH
 **/
macro anycast(any v, $Type) @builtin
{
	if (v.type != $Type.typeid) return CastResult.TYPE_MISMATCH?;
	return ($Type*)v.ptr;
}

struct CallstackElement
{
	CallstackElement* prev;
	String function;
	String file;
	uint line;
}

fn void default_panic(String message, String file, String function, uint line)
{
	CallstackElement* stack = $$stacktrace();
	$if ($defined(io::stderr) && $defined(File.printf))

	if (stack) stack = stack.prev;
	if (stack)
	{
		(void)io::stderr().print("\nERROR: '");
		(void)io::stderr().print(message);
		(void)io::stderr().printn("'");
	}
	else
	{
		(void)io::stderr().print("\nERROR: '");
		(void)io::stderr().print(message);
		(void)io::stderr().printfn("', in function %s (%s:%d)", function, file, line);
	}
	while (stack)
	{
		(void)io::stderr().printfn("  in function %s (%s:%d)", stack.function, stack.file, stack.line);
		if (stack == stack.prev) break;
		stack = stack.prev;
	}

	$endif
	$$trap();
}

def PanicFn = fn void(String message, String file, String function, uint line);

PanicFn panic = &default_panic;

fn void panicf(String fmt, String file, String function, uint line, args...)
{
	@stack_mem(512; Allocator* mem)
	{
		DString s;
		s.init(.using = mem);
		s.printf(fmt, ...args);
		panic(s.str(), file, function, line);
	};
}

/**
 * Marks the path as unreachable. This will panic in safe mode, and in fast will simply be assumed
 * never happens.
 * @param [in] string "The panic message or format string"
 **/
macro void unreachable(String string = "Unreachable statement reached.", ...) @builtin @noreturn
{
	panicf(string, $$FILE, $$FUNC, $$LINE, $vasplat());
	$$unreachable();
}

/**
 * Marks the path as unsupported, this is similar to unreachable.
 * @param [in] string "The error message"
 **/
macro void unsupported(String string = "Unsupported function invoked") @builtin @noreturn
{
	panicf(string, $$FILE, $$FUNC, $$LINE, $vasplat());
	$$unreachable();
}

/**
 * @param expr "the expression to cast"
 * @param $Type "the type to cast to"
 *
 * @require $sizeof(expr) == $Type.sizeof  "Cannot bitcast between types of different size."
 * @ensure @typeis(result, $Type)
 **/
macro bitcast(expr, $Type) @builtin
{
	usz $size = $sizeof(expr);
	$Type x @noinit;
	mem::copy(&x, &expr, $size, $Type.alignof, $alignof(expr));
	return x;
}

/**
 * @param $Type `The type of the enum`
 * @param [in] enum_name `The name of the enum to search for`
 * @require $Type.kindof == ENUM `Only enums may be used`
 * @ensure @typeis(return, $Type)
 * @return! SearchResult.MISSING
 **/
macro enum_by_name($Type, String enum_name) @builtin
{
	typeid x = $Type.typeid;
	foreach (i, name : x.names)
	{
		if (name == enum_name) return ($Type)i;
	}
	return SearchResult.MISSING?;
}

/**
 * Mark an expression as likely to be true
 *
 * @param #value "expression to be marked likely"
 * @param $probability "in the range 0 - 1"
 * @require $probability >= 0 && $probability <= 1.0
 **/
macro bool @likely(bool #value, $probability = 1.0) @builtin
{
$if ($probability == 1.0)
	return $$expect(#value, true);
$else
	return $$expect_with_probability(#value, true, $probability);
$endif
}

/**
 * Mark an expression as unlikely to be true
 *
 * @param #value "expression to be marked unlikely"
 * @param $probability "in the range 0 - 1"
 * @require $probability >= 0 && $probability <= 1.0
 **/
macro bool @unlikely(bool #value, $probability = 1.0) @builtin
{
$if ($probability == 1.0)
	return $$expect(#value, false);
$else
	return $$expect_with_probability(#value, false, $probability);
$endif
}

/**
 * @require values::@is_int(#value) || values::@is_bool(#value)
 * @checked $typeof(#value) a = expected
 * @require $probability >= 0 && $probability <= 1.0
 **/
macro @expect(#value, expected, $probability = 1.0) @builtin
{
    $if ($probability == 1.0)
	return $$expect(#value, ($typeof(#value))expected);
    $else
	return $$expect_with_probability(#value, expected, $probability);
    $endif
}

/**
 * Locality for prefetch, levels 0 - 3, corresponding
 * to "extremely local" to "no locality"
 **/
enum PrefetchLocality
{
	NO_LOCALITY,
	FAR,
	NEAR,
	VERY_NEAR,
}

/**
 * Prefetch a pointer.

 * @param [in] ptr `Pointer to prefetch`
 * @param $locality `Locality ranging from none to extremely local`
 * @param $write `Prefetch for write, otherwise prefetch for read.`
 **/
macro prefetch(void* ptr, PrefetchLocality $locality = VERY_NEAR, bool $write = false) @builtin
{
	$$prefetch(ptr, $write ? 1 : 0, $locality.ordinal);
}

macro swizzle(v, ...) @builtin
{
	return $$swizzle(v, $vasplat());
}

macro swizzle2(v, v2, ...) @builtin
{
	return $$swizzle2(v, v2, $vasplat());
}

macro bool @castable(#expr, $To) @builtin
{
	return $checks(($To)#expr);
}

macro bool @convertible(#expr, $To) @builtin
{
	return $checks($To x = #expr);
}

macro anyfault @catchof(#expr) @builtin
{
	if (catch f = #expr) return f;
    return anyfault {};
}

macro bool @ok(#expr) @builtin
{
	if (catch #expr) return false;
    return true;
}

macro uint int.hash(int i) => i;
macro uint uint.hash(uint i) => i;
macro uint short.hash(short s) => s;
macro uint ushort.hash(ushort s) => s;
macro uint char.hash(char c) => c;
macro uint ichar.hash(ichar c) => c;
macro uint long.hash(long i) => (uint)((i >> 32) ^ i);
macro uint ulong.hash(ulong i) => (uint)((i >> 32) ^ i);
macro uint int128.hash(int128 i) => (uint)((i >> 96) ^ (i >> 64) ^ (i >> 32) ^ i);
macro uint uint128.hash(uint128 i) => (uint)((i >> 96) ^ (i >> 64) ^ (i >> 32) ^ i);
macro uint bool.hash(bool b) => (uint)b;
macro uint typeid.hash(typeid t) => ((ulong)(uptr)t).hash();
macro uint String.hash(String c) => (uint)fnv32a::encode(c);
macro uint char[].hash(char[] c) => (uint)fnv32a::encode(c);
// Copyright (c) 2021-2022 Christoffer Lerno and contributors. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::builtin;

/**
 * @require types::is_comparable_value(a) && types::is_comparable_value(b)
 **/
macro less(a, b) @builtin
{
$switch
	$case $defined(a.less):
		return a.less(b);
	$case $defined(a.compare_to):
		return a.compare_to(b) < 0;
	$default:
		return a < b;
$endswitch
}

/**
 * @require types::is_comparable_value(a) && types::is_comparable_value(b)
 **/
macro less_eq(a, b) @builtin
{
$switch
	$case $defined(a.less):
		return !b.less(a);
	$case $defined(a.compare_to):
		return a.compare_to(b) <= 0;
	$default:
		return a <= b;
$endswitch
}

/**
 * @require types::is_comparable_value(a) && types::is_comparable_value(b)
 **/
macro greater(a, b) @builtin
{
$switch
	$case $defined(a.less):
		return b.less(a);
	$case $defined(a.compare_to):
		return a.compare_to(b) > 0;
	$default:
		return a > b;
$endswitch
}

/**
 * @require types::is_comparable_value(a) && types::is_comparable_value(b)
 **/
macro greater_eq(a, b) @builtin
{
$switch
	$case $defined(a.less):
		return !a.less(b);
	$case $defined(a.compare_to):
		return a.compare_to(b) >= 0;
	$default:
		return a >= b;
$endswitch
}

/**
 * @require types::is_equatable_value(a) && types::is_equatable_value(b) `values must be equatable`
 **/
macro bool equals(a, b) @builtin
{
$switch
	$case $defined(a.equals):
		return a.equals(b);
	$case $defined(a.compare_to):
		return a.compare_to(b) == 0;
	$case $defined(a.less):
		return !a.less(b) && !b.less(a);
	$default:
		return a == b;
$endswitch
}

macro min(x, ...) @builtin
{
    $if ($vacount == 1)
        return less(x, $vaarg(0)) ? x : $vaarg(0);
    $else
        var result = x;
        $for (var $i = 0; $i < $vacount; $i++)
            if (less($vaarg($i), result))
            {
                 result = $vaarg($i);
            }
        $endfor
        return result;
    $endif
}

macro max(x, ...) @builtin
{
    $if ($vacount == 1)
        return greater(x, $vaarg(0)) ? x : $vaarg(0);
    $else
        var result = x;
        $for (var $i = 0; $i < $vacount; $i++)
            if (greater($vaarg($i), result))
            {
                 result = $vaarg($i);
            }
        $endfor
        return result;
    $endif
}

// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::cinterop;

const C_INT_SIZE = $$C_INT_SIZE;
const C_LONG_SIZE = $$C_LONG_SIZE;
const C_SHORT_SIZE = $$C_SHORT_SIZE;
const C_LONG_LONG_SIZE = $$C_LONG_LONG_SIZE;

$assert (C_SHORT_SIZE < 32);
$assert (C_INT_SIZE < 128);
$assert (C_LONG_SIZE < 128);
$assert (C_LONG_LONG_SIZE <= 128);
$assert (C_SHORT_SIZE <= C_INT_SIZE);
$assert (C_INT_SIZE <= C_LONG_SIZE);
$assert (C_LONG_SIZE <= C_LONG_LONG_SIZE);

$switch ($$C_INT_SIZE)
$case 64:
    def CInt = long;
    def CUInt = ulong;
$case 32:
    def CInt = int;
    def CUInt = uint;
$case 16:
    def CInt = short;
    def CUInt = ushort;
$default:
    $assert(false, "Invalid C int size");
$endswitch

$switch ($$C_LONG_SIZE)
$case 64:
    def CLong = long;
    def CULong = ulong;
$case 32:
    def CLong = int;
    def CULong = uint;
$case 16:
    def CLong = short;
    def CULong = ushort;
$default:
    $assert(false, "Invalid C long size");
$endswitch

$switch ($$C_SHORT_SIZE)
$case 32:
    def CShort = int;
    def CUShort = uint;
$case 16:
    def CShort = short;
    def CUShort = ushort;
$case 8:
    def CShort = ichar;
    def CUShort = char;
$default:
    $assert(false, "Invalid C short size");
$endswitch

$switch ($$C_LONG_LONG_SIZE)
$case 128:
    def CLongLong = int128;
    def CULongLong = uint128;
$case 64:
    def CLongLong = long;
    def CULongLong = ulong;
$case 32:
    def CLongLong = int;
    def CULongLong = uint;
$case 16:
    def CLongLong = short;
    def CULongLong = ushort;
$default:
    $assert(false, "Invalid C long long size");
$endswitch



def CSChar = ichar;
def CUChar = char;

$if ($$C_CHAR_IS_SIGNED)
    def CChar = ichar;
$else
    def CChar = char;
$endif
module std::core::string::conv;

const uint UTF16_SURROGATE_OFFSET @private = 0x10000;
const uint UTF16_SURROGATE_GENERIC_MASK @private = 0xF800;
const uint UTF16_SURROGATE_GENERIC_VALUE @private = 0xD800;
const uint UTF16_SURROGATE_MASK @private = 0xFC00;
const uint UTF16_SURROGATE_CODEPOINT_MASK @private = 0x03FF;
const uint UTF16_SURROGATE_BITS @private = 10;
const uint UTF16_SURROGATE_LOW_VALUE @private = 0xDC00;
const uint UTF16_SURROGATE_HIGH_VALUE @private = 0xD800;

/**
 * @param c `The utf32 codepoint to convert`
 * @param [out] output `the resulting buffer`
 * @param available `the size available`
 **/
fn usz! char32_to_utf8(Char32 c, char* output, usz available)
{
	if (!available) return UnicodeResult.CONVERSION_FAILED?;
	switch (true)
	{
		case c <= 0x7f:
			output[0] = (char)c;
			return 1;
		case c <= 0x7ff:
	        if (available < 2) return UnicodeResult.CONVERSION_FAILED?;
			output[0] = (char)(0xC0 | c >> 6);
            output[1] = (char)(0x80 | (c & 0x3F));
            return 2;
        case c <= 0xffff:
	        if (available < 3) return UnicodeResult.CONVERSION_FAILED?;
            output[0] = (char)(0xE0 | c >> 12);
            output[1] = (char)(0x80 | (c >> 6 & 0x3F));
            output[2] = (char)(0x80 | (c & 0x3F));
            return 3;
        case c <= 0x10ffff:
	        if (available < 4) return UnicodeResult.CONVERSION_FAILED?;
		    output[0] = (char)(0xF0 | c >> 18);
            output[1] = (char)(0x80 | (c >> 12 & 0x3F));
            output[2] = (char)(0x80 | (c >> 6 & 0x3F));
            output[3] = (char)(0x80 | (c & 0x3F));
            return 4;
        default:
            // 0x10FFFF and above is not defined.
            return UnicodeResult.CONVERSION_FAILED?;
	}
}

/**
 * Convert a code pointer into 1-2 UTF16 characters.
 *
 * @param c `The character to convert.`
 * @param [inout] output `the resulting UTF16 buffer to write to.`
 **/
fn void char32_to_utf16_unsafe(Char32 c, Char16** output)
{
	if (c < UTF16_SURROGATE_OFFSET)
	{
		(*output)++[0] = (Char16)c;
		return;
	}
	c -= UTF16_SURROGATE_OFFSET;
	Char16 low = (Char16)(UTF16_SURROGATE_LOW_VALUE | (c & UTF16_SURROGATE_CODEPOINT_MASK));
	c >>= UTF16_SURROGATE_BITS;
	Char16 high = (Char16)(UTF16_SURROGATE_HIGH_VALUE | (c & UTF16_SURROGATE_CODEPOINT_MASK));
	(*output)++[0] = (Char16)high;
	(*output)++[0] = (Char16)low;
}

/**
 * Convert 1-2 UTF16 data points into UTF8.
 *
 * @param [in] ptr `The UTF16 data to convert.`
 * @param [inout] available `amount of UTF16 data available.`
 * @param [inout] output `the resulting utf8 buffer to write to.`
 **/
fn void! char16_to_utf8_unsafe(Char16 *ptr, usz *available, char** output)
{
	Char16 high = *ptr;
	if (high & UTF16_SURROGATE_GENERIC_MASK != UTF16_SURROGATE_GENERIC_VALUE)
	{
		char32_to_utf8_unsafe(high, output);
		*available = 1;
		return;
	}
    // Low surrogate first is an error
	if (high & UTF16_SURROGATE_MASK != UTF16_SURROGATE_HIGH_VALUE) return UnicodeResult.INVALID_UTF16?;

	// Unmatched high surrogate is an error
	if (*available == 1) return UnicodeResult.INVALID_UTF16?;

	Char16 low = ptr[1];

	// Unmatched high surrogate, invalid
	if (low & UTF16_SURROGATE_MASK != UTF16_SURROGATE_LOW_VALUE) return UnicodeResult.INVALID_UTF16?;

    // The high bits of the codepoint are the value bits of the high surrogate
    // The low bits of the codepoint are the value bits of the low surrogate
    Char32 uc = (high & UTF16_SURROGATE_CODEPOINT_MASK) << UTF16_SURROGATE_BITS
                | (low & UTF16_SURROGATE_CODEPOINT_MASK) + UTF16_SURROGATE_OFFSET;
	char32_to_utf8_unsafe(uc, output);
	*available = 2;
}
/**
 * @param c `The utf32 codepoint to convert`
 * @param [inout] output `the resulting buffer`
 **/
fn void char32_to_utf8_unsafe(Char32 c, char** output)
{
	switch (true)
	{
		case c < 0x7f:
			(*output)++[0] = (char)c;
		case c < 0x7ff:
			(*output)++[0] = (char)(0xC0 | c >> 6);
            (*output)++[0] = (char)(0x80 | (c & 0x3F));
        case c < 0xffff:
	        (*output)++[0] = (char)(0xE0 | c >> 12);
            (*output)++[0] = (char)(0x80 | (c >> 6 & 0x3F));
            (*output)++[0] = (char)(0x80 | (c & 0x3F));
        default:
	 	    (*output)++[0] = (char)(0xF0 | c >> 18);
            (*output)++[0] = (char)(0x80 | (c >> 12 & 0x3F));
            (*output)++[0] = (char)(0x80 | (c >> 6 & 0x3F));
            (*output)++[0] = (char)(0x80 | (c & 0x3F));
	}
}

/**
 * @param [in] ptr `pointer to the first character to parse`
 * @param [inout] size `Set to max characters to read, set to characters read`
 * @return `the parsed 32 bit codepoint`
 **/
fn Char32! utf8_to_char32(char* ptr, usz* size)
{
	usz max_size = *size;
	if (max_size < 1) return UnicodeResult.INVALID_UTF8?;
	char c = (ptr++)[0];

    if ((c & 0x80) == 0)
    {
        *size = 1;
        return c;
    }
    if ((c & 0xE0) == 0xC0)
    {
		if (max_size < 2) return UnicodeResult.INVALID_UTF8?;
        *size = 2;
        Char32 uc = (c & 0x1F) << 6;
        c = *ptr;
        // Overlong sequence or invalid second.
		if (!uc || c & 0xC0 != 0x80) return UnicodeResult.INVALID_UTF8?;
		return uc + c & 0x3F;
    }
    if ((c & 0xF0) == 0xE0)
    {
		if (max_size < 3) return UnicodeResult.INVALID_UTF8?;
        *size = 3;
        Char32 uc = (c & 0x0F) << 12;
		c = ptr++[0];
		if (c & 0xC0 != 0x80) return UnicodeResult.INVALID_UTF8?;
		uc += (c & 0x3F) << 6;
		c = ptr++[0];
		// Overlong sequence or invalid last
		if (!uc || c & 0xC0 != 0x80) return UnicodeResult.INVALID_UTF8?;
		return uc + c & 0x3F;
    }
    if (max_size < 4) return UnicodeResult.INVALID_UTF8?;
    if ((c & 0xF8) != 0xF0) return UnicodeResult.INVALID_UTF8?;
    *size = 4;
    Char32 uc = (c & 0x07) << 18;
	c = ptr++[0];
	if (c & 0xC0 != 0x80) return UnicodeResult.INVALID_UTF8?;
	uc += (c & 0x3F) << 12;
	c = ptr++[0];
	if (c & 0xC0 != 0x80) return UnicodeResult.INVALID_UTF8?;
	uc += (c & 0x3F) << 6;
	c = ptr++[0];
	// Overlong sequence or invalid last
	if (!uc || c & 0xC0 != 0x80) return UnicodeResult.INVALID_UTF8?;
	return uc + c & 0x3F;
}

/**
 * @param utf8 `An UTF-8 encoded slice of bytes`
 * @return `the number of encoded code points`
 **/
fn usz utf8_codepoints(String utf8)
{
	usz len = 0;
	foreach (char c : utf8)
	{
		if (c & 0xC0 != 0x80) len++;
	}
	return len;
}

/**
 * Calculate the UTF8 length required to encode an UTF32 array.
 * @param [in] utf32 `the utf32 data to calculate from`
 * @return `the length of the resulting UTF8 array`
 **/
fn usz utf8len_for_utf32(Char32[] utf32)
{
	usz len = 0;
	foreach (Char32 uc : utf32)
	{
		switch (true)
		{
			case uc < 0x7f:
				len++;
			case uc < 0x7ff:
				len += 2;
			case uc < 0xffff:
				len += 3;
			default:
				len += 4;
		}
	}
	return len;
}

/**
 * Calculate the UTF8 length required to encode an UTF16 array.
 * @param [in] utf16 `the utf16 data to calculate from`
 * @return `the length of the resulting UTF8 array`
 **/
fn usz utf8len_for_utf16(Char16[] utf16)
{
	usz len = 0;
	usz len16 = utf16.len;
	for (usz i = 0; i < len16; i++)
	{
		Char16 c = utf16[i];
		if (c & UTF16_SURROGATE_GENERIC_MASK != UTF16_SURROGATE_GENERIC_VALUE)
		{
			if (c < 0x7f)
			{
				len++;
				continue;
			}
			if (c < 0x7ff)
			{
				len += 2;
				continue;
			}
			len += 3;
			continue;
		}
		len += 4;
	}
	return len;
}

/**
 * Calculate the UTF16 length required to encode a UTF8 array.
 * @param utf8 `the utf8 data to calculate from`
 * @return `the length of the resulting UTF16 array`
 **/
fn usz utf16len_for_utf8(String utf8)
{
	usz len = utf8.len;
	usz len16 = 0;
	for (usz i = 0; i < len; i++)
	{
		len16++;
		char c = utf8[i];
		if (c & 0x80 == 0) continue;
		i++;
		if (c & 0xE0 == 0xC0) continue;
		i++;
		if (c & 0xF0 == 0xE0) continue;
		i++;
		len16++;
    }
    return len16;
}

/**
 * @param [in] utf32 `the UTF32 array to check the length for`
 * @return `the required length of an UTF16 array to hold the UTF32 data.`
 **/
fn usz utf16len_for_utf32(Char32[] utf32)
{
	usz len = utf32.len;
	foreach (Char32 uc : utf32)
	{
		if (uc >= UTF16_SURROGATE_OFFSET) len++;
	}
	return len;
}

/**
 * Convert an UTF32 array to an UTF8 array.
 *
 * @param [in] utf32
 * @param [out] utf8_buffer
 * @return `the number of bytes written.`
 **/
fn usz! utf32to8(Char32[] utf32, String utf8_buffer)
{
	usz len = utf8_buffer.len;
	char* ptr = utf8_buffer.ptr;
	foreach (Char32 uc : utf32)
	{
		usz used = char32_to_utf8(uc, ptr, len) @inline!;
		len -= used;
		ptr += used;
	}
	// Zero terminate if there is space.
    if (len > 0) ptr[0] = 0;
	return utf8_buffer.len - len;
}

/**
 * Convert an UTF8 array to an UTF32 array.
 *
 * @param [in] utf8
 * @param [out] utf32_buffer
 * @return `the number of Char32s written.`
 **/
fn usz! utf8to32(String utf8, Char32[] utf32_buffer)
{
	usz len = utf8.len;
	Char32* ptr = utf32_buffer.ptr;
    usz len32 = 0;
    usz buf_len = utf32_buffer.len;
    for (usz i = 0; i < len;)
    {
        if (len32 == buf_len) return UnicodeResult.CONVERSION_FAILED?;
        usz width = len - i;
    	Char32 uc = utf8_to_char32(&utf8[i], &width) @inline!;
    	i += width;
    	ptr[len32++] = uc;
    }
    // Zero terminate if possible
    if (len32 + 1 < buf_len) ptr[len32] = 0;
    return len32;
}

/**
 * Copy an array of UTF16 data into an UTF8 buffer without bounds
 * checking. This will assume the buffer is sufficiently large to hold
 * the converted data.
 *
 * @param [in] utf16 `The UTF16 array containing the data to convert.`
 * @param [out] utf8_buffer `the (sufficiently large) buffer to hold the UTF16 data.`
 **/
fn void! utf16to8_unsafe(Char16[] utf16, char* utf8_buffer)
{
	usz len16 = utf16.len;
	for (usz i = 0; i < len16;)
	{
		usz available = len16 - i;
		char16_to_utf8_unsafe(&utf16[i], &available, &utf8_buffer) @inline!;
		i += available;
	}
}

/**
 * Copy an array of UTF8 data into an UTF32 buffer without bounds
 * checking. This will assume the buffer is sufficiently large to hold
 * the converted data.
 *
 * @param [in] utf8 `The UTF8 buffer containing the data to convert.`
 * @param [out] utf32_buffer `the (sufficiently large) buffer to hold the UTF8 data.`
 **/
fn void! utf8to32_unsafe(String utf8, Char32* utf32_buffer)
{
	usz len = utf8.len;
	for (usz i = 0; i < len;)
    {
        usz width = len - i;
    	Char32 uc = utf8_to_char32(&utf8[i], &width) @inline!;
    	i += width;
    	(utf32_buffer++)[0] = uc;
    }
}

/**
 * Copy an array of UTF8 data into an UTF16 buffer without bounds
 * checking. This will assume the buffer is sufficiently large to hold
 * the converted data.
 *
 * @param [in] utf8 `The UTF8 buffer containing the data to convert.`
 * @param [out] utf16_buffer `the (sufficiently large) buffer to hold the UTF8 data.`
 **/
fn void! utf8to16_unsafe(String utf8, Char16* utf16_buffer)
{
	usz len = utf8.len;
    for (usz i = 0; i < len;)
    {
        usz width = len - i;
    	Char32 uc = utf8_to_char32(&utf8[i], &width) @inline!;
        char32_to_utf16_unsafe(uc, &utf16_buffer) @inline;
        i += width;
    }
}

/**
 * Copy an array of UTF32 code points into an UTF8 buffer without bounds
 * checking. This will assume the buffer is sufficiently large to hold
 * the converted data.
 *
 * @param [in] utf32 `The UTF32 buffer containing the data to convert.`
 * @param [out] utf8_buffer `the (sufficiently large) buffer to hold the UTF8 data.`
 **/
fn void utf32to8_unsafe(Char32[] utf32, char* utf8_buffer)
{
	char* start = utf8_buffer;
	foreach (Char32 uc : utf32)
	{
		char32_to_utf8_unsafe(uc, &utf8_buffer) @inline;
	}
}
module std::core::dstring;

def DString = distinct void*;

const usz MIN_CAPACITY @private = 16;

/**
 * @require !str.data() "String already initialized"
 **/
fn void DString.init(DString *str, usz capacity = MIN_CAPACITY, Allocator* using = mem::heap())
{
	if (capacity < MIN_CAPACITY) capacity = MIN_CAPACITY;
	StringData* data = malloc(StringData, 1, .using = using, .end_padding = capacity);
	data.allocator = using;
	data.len = 0;
	data.capacity = capacity;
	*str = (DString)data;
}

/**
 * @require !str.data() "String already initialized"
 **/
fn void DString.tinit(DString *str, usz capacity = MIN_CAPACITY) => str.init(capacity, mem::temp()) @inline;

fn DString new_with_capacity(usz capacity, Allocator* using = mem::heap())
{
	DString dstr;
	dstr.init(capacity, using);
	return dstr;
}

fn DString tnew_with_capacity(usz capacity) => new_with_capacity(capacity, mem::temp()) @inline;

fn DString new(String c = "", Allocator* using = mem::heap())
{
	usz len = c.len;
	StringData* data = (StringData*)new_with_capacity(len, using);
	if (len)
	{
		data.len = len;
		mem::copy(&data.chars, c.ptr, len);
	}
	return (DString)data;
}

fn DString tnew(String s = "") => new(s, mem::temp()) @inline;

fn DString DString.new_concat(DString a, DString b, Allocator* using = mem::heap())
{
	DString string;
	string.init(a.len() + b.len(), using);
	string.append(a);
	string.append(b);
	return string;
}

fn DString DString.new_tconcat(DString a, DString b) => a.new_concat(b, mem::temp());

fn ZString DString.zstr(DString str)
{
	StringData* data = str.data();
	if (!data) return "";
	if (data.capacity == data.len)
	{
		str.reserve(1);
		data.chars[data.len] = 0;
	}
	else if (data.chars[data.len] != 0)
	{
		data.chars[data.len] = 0;
	}
	return (ZString)&data.chars[0];
}

fn usz DString.capacity(DString this)
{
	if (!this) return 0;
	return this.data().capacity;
}

fn usz DString.len(DString this)
{
	if (!this) return 0;
	return this.data().len;
}

/**
 * @require new_size <= this.len()
 */
fn void DString.chop(DString this, usz new_size)
{
	if (!this) return;
	this.data().len = new_size;
}

fn String DString.str(DString str)
{
	StringData* data = (StringData*)str;
	if (!data) return "";
	return (String)data.chars[:data.len];
}

fn void DString.append_utf32(DString* str, Char32[] chars)
{
	str.reserve(chars.len);
	foreach (Char32 c : chars)
	{
		str.append_char32(c);
	}
}

/**
 * @require index < str.len()
 **/
fn void DString.set(DString str, usz index, char c)
{
	str.data().chars[index] = c;
}

fn void DString.append_repeat(DString* str, char c, usz times)
{
	if (times == 0) return;
	str.reserve(times);
	StringData* data = str.data();
	for (usz i = 0; i < times; i++)
	{
        data.chars[data.len++] = c;
	}
}

/**
 * @require c <= 0x10ffff
 */
fn void DString.append_char32(DString* str, Char32 c)
{
	if (c < 0x7f)
	{
		str.reserve(1);
		StringData* data = str.data();
        data.chars[data.len++] = (char)c;
        return;
    }
    if (c < 0x7ff)
    {
		str.reserve(2);
		StringData* data = str.data();
		data.chars[data.len++] = (char)(0xC0 | c >> 6);
        data.chars[data.len++] = (char)(0x80 | (c & 0x3F));
        return;
    }
    if (c < 0xffff)
    {
		str.reserve(3);
		StringData* data = str.data();
		data.chars[data.len++] = (char)(0xE0 | c >> 12);
        data.chars[data.len++] = (char)(0x80 | (c >> 6 & 0x3F));
        data.chars[data.len++] = (char)(0x80 | (c & 0x3F));
        return;
    }
	str.reserve(4);
	StringData* data = str.data();
	data.chars[data.len++] = (char)(0xF0 | c >> 18);
    data.chars[data.len++] = (char)(0x80 | (c >> 12 & 0x3F));
    data.chars[data.len++] = (char)(0x80 | (c >> 6 & 0x3F));
    data.chars[data.len++] = (char)(0x80 | (c & 0x3F));
}

fn DString DString.tcopy(DString* str) => str.copy(mem::temp());

fn DString DString.copy(DString* str, Allocator* using = null)
{
	if (!str)
	{
		if (using) return new_with_capacity(0, using);
		return (DString)null;
	}
	if (!using) using = mem::heap();
	StringData* data = str.data();
	DString new_string = new_with_capacity(data.capacity, using);
	mem::copy((char*)new_string.data(), (char*)data, StringData.sizeof + data.len);
	return new_string;
}

fn ZString DString.copy_zstr(DString* str, Allocator* using = mem::heap())
{
	usz str_len = str.len();
	if (!str_len)
	{
		return (ZString)calloc(1, .using = using);
	}
	char* zstr = malloc(str_len + 1, .using = using);
	StringData* data = str.data();
	mem::copy(zstr, &data.chars, str_len);
	zstr[str_len] = 0;
	return (ZString)zstr;
}

fn String DString.copy_str(DString* str, Allocator* using = mem::heap())
{
	return (String)str.copy_zstr(using)[:str.len()];
}

fn String DString.tcopy_str(DString* str) => str.copy_str(mem::temp()) @inline;

fn bool DString.equals(DString str, DString other_string)
{
	StringData *str1 = str.data();
	StringData *str2 = other_string.data();
	if (str1 == str2) return true;
	if (!str1) return str2.len == 0;
	if (!str2) return str1.len == 0;
	usz str1_len = str1.len;
	if (str1_len != str2.len) return false;
	for (int i = 0; i < str1_len; i++)
	{
		if (str1.chars[i] != str2.chars[i]) return false;
	}
	return true;
}

fn void DString.free(DString* str)
{
	if (!*str) return;
	StringData* data = str.data();
	if (!data) return;
	free(data, .using = data.allocator);
	*str = (DString)null;
}

fn bool DString.less(DString str, DString other_string)
{
	StringData* str1 = str.data();
	StringData* str2 = other_string.data();
	if (str1 == str2) return false;
	if (!str1) return str2.len != 0;
	if (!str2) return str1.len == 0;
	usz str1_len = str1.len;
	usz str2_len = str2.len;
	if (str1_len != str2_len) return str1_len < str2_len;
	for (int i = 0; i < str1_len; i++)
	{
		if (str1.chars[i] >= str2.chars[i]) return false;
	}
	return true;
}

fn void DString.append_chars(DString* this, String str)
{
	usz other_len = str.len;
	if (!other_len) return;
	if (!*this)
	{
		*this = new(str);
		return;
	}
	this.reserve(other_len);
	StringData* data = (StringData*)*this;
	mem::copy(&data.chars[data.len], str.ptr, other_len);
	data.len += other_len;
}

fn Char32[] DString.copy_utf32(DString* this, Allocator* using = mem::heap())
{
	return this.str().to_utf32(using) @inline!!;
}

fn void DString.append_string(DString* this, DString str)
{
	StringData* other = (StringData*)str;
	if (!other) return;
	this.append(str.str());
}

fn void DString.clear(DString* str)
{
	str.data().len = 0;
}

fn void DString.append_char(DString* str, char c)
{
	if (!*str)
	{
		*str = new_with_capacity(MIN_CAPACITY);
	}
	str.reserve(1);
	StringData* data = (StringData*)*str;
	data.chars[data.len++] = c;
}


macro void DString.append(DString* str, value)
{
	var $Type = $typeof(value);
	$switch ($Type)
		$case char:
		$case ichar:
			str.append_char(value);
		$case DString:
			str.append_string(value);
		$case String:
			str.append_chars(value);
		$case Char32:
			str.append_char32(value);
		$default:
			$switch
				$case @convertible(value, Char32):
					str.append_char32(value);
				$case @convertible(value, String):
					str.append_chars(value);
				$default:
					$assert(false, "Unsupported type for append – use printf instead.");
			$endswitch
	$endswitch
}


fn usz! DString.printf(DString* str, String format, args...) @maydiscard
{
	Formatter formatter;
	formatter.init(&out_string_append_fn, str);
	return formatter.vprintf(format, args);
}

fn usz! DString.printfn(DString* str, String format, args...) @maydiscard
{
	Formatter formatter;
	formatter.init(&out_string_append_fn, str);
	usz len = formatter.vprintf(format, args)!;
	str.append('\n');
	return len + 1;
}

fn DString new_join(String[] s, String joiner, Allocator* using = mem::heap())
{
	if (!s.len) return (DString)null;
	usz total_size = joiner.len * s.len;
	foreach (String* &str : s)
	{
		total_size += str.len;
	}
	DString res = new_with_capacity(total_size, using);
	res.append(s[0]);
	foreach (String* &str : s[1..])
	{
		res.append(joiner);
		res.append(*str);
	}
	return res;
}

fn void! out_string_append_fn(char c, void* data) @private
{
	DString* s = data;
	s.append_char(c);
}


fn StringData* DString.data(DString str) @inline @private
{
	return (StringData*)str;
}

fn void DString.reserve(DString* str, usz addition)
{
	StringData* data = str.data();
	if (!data)
	{
		*str = dstring::new_with_capacity(addition);
		return;
	}
	usz len = data.len + addition;
	if (data.capacity >= len) return;
	usz new_capacity = data.capacity *= 2;
	if (new_capacity < MIN_CAPACITY) new_capacity = MIN_CAPACITY;
	*str = (DString)realloc(data, StringData.sizeof + new_capacity, .using = data.allocator);
}

fn usz! DString.read_from_stream(DString* string, Stream* reader)
{
	if (reader.supports_available())
	{
		usz total_read = 0;
		while (usz available = reader.available()!)
		{
			string.reserve(available);
			StringData* data = string.data();
			usz len = reader.read(data.chars[data.len..(data.capacity - 1)])!;
			total_read += len;
			data.len += len;
		}
		return total_read;
	}
	usz total_read = 0;
	while (true)
	{
		// Reserve at least 16 bytes
		string.reserve(16);
		StringData* data = string.data();
		// Read into the rest of the buffer
		usz read = reader.read(data.chars[data.len..(data.capacity - 1)])!;
		data.len += read;
		// Ok, we reached the end.
		if (read < 16) return total_read;
		// Otherwise go another round
	}
}

struct StringData @private
{
	Allocator* allocator;
	usz len;
	usz capacity;
	char[*] chars;
}
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::env;
import libc;
enum CompilerOptLevel
{
    O0,
    O1,
    O2,
    O3
}

enum MemoryEnvironment
{
	NORMAL,
	SMALL,
	TINY,
	NONE
}

enum OsType
{
	UNKNOWN,
	NONE,
	ANANAS,
	CLOUD_ABI,
	DRAGON_FLY,
	FREEBSD,
	FUCHSIA,
	IOS,
	KFREEBSD,
	LINUX,
	PS3,
	MACOS,
	NETBSD,
	OPENBSD,
	SOLARIS,
	WIN32,
	HAIKU,
	MINIX,
	RTEMS,
	NACL,       // Native Client
	CNK,        // BG/P Compute-Node Kernel
	AIX,
	CUDA,
	NVOPENCL,
	AMDHSA,
	PS4,
	ELFIAMCU,
	TVOS,
	WATCHOS,
	MESA3D,
	CONTIKI,
	AMDPAL,
	HERMITCORE,
	HURD,
	WASI,
	EMSCRIPTEN,
}

enum ArchType
{
	UNKNOWN,
	ARM,          // ARM (little endian): arm, armv.*, xscale
	ARMB,         // ARM (big endian): armeb
	AARCH64,      // AArch64 (little endian): aarch64
	AARCH64_BE,   // AArch64 (big endian): aarch64_be
	AARCH64_32,   // AArch64 (little endian) ILP32: aarch64_32
	ARC,          // ARC: Synopsys ARC
	AVR,          // AVR: Atmel AVR microcontroller
	BPFEL,        // eBPF or extended BPF or 64-bit BPF (little endian)
	BPFEB,        // eBPF or extended BPF or 64-bit BPF (big endian)
	HEXAGON,      // Hexagon: hexagon
	MIPS,         // MIPS: mips, mipsallegrex, mipsr6
	MIPSEL,       // MIPSEL: mipsel, mipsallegrexe, mipsr6el
	MIPS64,       // MIPS64: mips64, mips64r6, mipsn32, mipsn32r6
	MIPS64EL,     // MIPS64EL: mips64el, mips64r6el, mipsn32el, mipsn32r6el
	MSP430,       // MSP430: msp430
	PPC,          // PPC: powerpc
	PPC64,        // PPC64: powerpc64, ppu
	PPC64LE,      // PPC64LE: powerpc64le
	R600,         // R600: AMD GPUs HD2XXX - HD6XXX
	AMDGCN,       // AMDGCN: AMD GCN GPUs
	RISCV32,      // RISC-V (32-bit): riscv32
	RISCV64,      // RISC-V (64-bit): riscv64
	SPARC,        // Sparc: sparc
	SPARCV9,      // Sparcv9: Sparcv9
	SPARCEL,      // Sparc: (endianness = little). NB: 'Sparcle' is a CPU variant
	SYSTEMZ,      // SystemZ: s390x
	TCE,          // TCE (http://tce.cs.tut.fi/): tce
	TCELE,        // TCE little endian (http://tce.cs.tut.fi/): tcele
	THUMB,        // Thumb (little endian): thumb, thumbv.*
	THUMBEB,      // Thumb (big endian): thumbeb
	X86,          // X86: i[3-9]86
	X86_64,       // X86-64: amd64, x86_64
	XCORE,        // XCore: xcore
	NVPTX,        // NVPTX: 32-bit
	NVPTX64,      // NVPTX: 64-bit
	LE32,         // le32: generic little-endian 32-bit CPU (PNaCl)
	LE64,         // le64: generic little-endian 64-bit CPU (PNaCl)
	AMDIL,        // AMDIL
	AMDIL64,      // AMDIL with 64-bit pointers
	HSAIL,        // AMD HSAIL
	HSAIL64,      // AMD HSAIL with 64-bit pointers
	SPIR,         // SPIR: standard portable IR for OpenCL 32-bit version
	SPIR64,       // SPIR: standard portable IR for OpenCL 64-bit version
	KALIMBA,      // Kalimba: generic kalimba
	SHAVE,        // SHAVE: Movidius vector VLIW processors
	LANAI,        // Lanai: Lanai 32-bit
	WASM32,       // WebAssembly with 32-bit pointers
	WASM64,       // WebAssembly with 64-bit pointers
	RSCRIPT32,    // 32-bit RenderScript
	RSCRIPT64,    // 64-bit RenderScript
}

const OsType OS_TYPE = (OsType)$$OS_TYPE;
const ArchType ARCH_TYPE = (ArchType)$$ARCH_TYPE;
const bool COMPILER_LIBC_AVAILABLE = $$COMPILER_LIBC_AVAILABLE;
const CompilerOptLevel COMPILER_OPT_LEVEL = (CompilerOptLevel)$$COMPILER_OPT_LEVEL;
const bool BIG_ENDIAN = $$PLATFORM_BIG_ENDIAN;
const bool I128_NATIVE_SUPPORT = $$PLATFORM_I128_SUPPORTED;
const bool F16_SUPPORT = $$PLATFORM_F16_SUPPORTED;
const bool F128_SUPPORT = $$PLATFORM_F128_SUPPORTED;
const bool COMPILER_SAFE_MODE = $$COMPILER_SAFE_MODE;
const usz LLVM_VERSION = $$LLVM_VERSION;
const bool BENCHMARKING = $$BENCHMARKING;
const bool TESTING = $$TESTING;
const MemoryEnvironment MEMORY_ENV = (MemoryEnvironment)$$MEMORY_ENVIRONMENT;

macro bool os_is_win32()
{
	return OS_TYPE == WIN32;
}

macro bool os_is_darwin()
{
	$switch (OS_TYPE)
	$case IOS:
	$case MACOS:
	$case TVOS:
	$case WATCHOS:
		return true;
	$default:
		return false;
	$endswitch
}

macro bool os_is_posix()
{
	$switch (OS_TYPE)
	$case IOS:
	$case MACOS:
	$case NETBSD:
	$case LINUX:
	$case KFREEBSD:
	$case FREEBSD:
	$case OPENBSD:
	$case SOLARIS:
	$case TVOS:
	$case WATCHOS:
		return true;
	$case WIN32:
	$case WASI:
	$case EMSCRIPTEN:
		return false;
	$default:
		$echo("Assuming non-Posix environment");
		return false;
	$endswitch
}


/**
 * @param [&in] name
 * @require name.len > 0
 **/
fn String! get_var(String name)
{
$if (COMPILER_LIBC_AVAILABLE && !os_is_win32())
	@pool()
	{
		ZString val = libc::getenv(name.zstr_tcopy());
		return val ? val.as_str() : SearchResult.MISSING?;
	};
$else
	return "";
$endif
}


/**
 * @param [&in] name
 * @param [&in] value
 * @require name.len > 0
 **/
fn void set_var(String name, String value, bool overwrite = true)
{
$if (COMPILER_LIBC_AVAILABLE && !os_is_win32())
	@pool()
	{
		if (libc::setenv(name.zstr_tcopy(), value.zstr_copy(), (int)overwrite))
		{
			unreachable();
		}
	};
$endif
}

/**
 * @param [&in] name
 * @require name.len > 0
 **/
fn void clear_var(String name)
{
$if (COMPILER_LIBC_AVAILABLE && !os_is_win32())
	@pool()
	{
		if (libc::unsetenv(name.zstr_tcopy()))
		{
			unreachable();
		}
	};
$endif
}

// Copyright (c) 2021-2023 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::mem;

const MAX_MEMORY_ALIGNMENT = 0x1000_0000;
const DEFAULT_MEM_ALIGNMENT = (void*.alignof) * 2;


macro @volatile_load(&x) @builtin
{
    return $$volatile_load(&x);
}

macro @volatile_store(&x, y) @builtin
{
    return $$volatile_store(&x, ($typeof(x))y);
}

enum AtomicOrdering : int
{
	NOT_ATOMIC,         // Not atomic
	UNORDERED,          // No lock
	MONOTONIC,          // Consistent ordering
	ACQUIRE,            // Barrier locking load/store
	RELEASE,            // Barrier releasing load/store
	ACQUIRE_RELEASE,    // Barrier fence to load/store
	SEQ_CONSISTENT,     // Acquire semantics, ordered with other seq_consistent
}

/**
 * @param [in] x "the variable or dereferenced pointer to load."
 * @param $ordering "atomic ordering of the load, defaults to SEQ_CONSISTENT"
 * @param $volatile "whether the load should be volatile, defaults to 'false'"
 * @return "returns the value of x"
 *
 * @require $ordering != AtomicOrdering.RELEASE "Release ordering is not valid for load."
 * @require $ordering != AtomicOrdering.ACQUIRE_RELEASE "Acquire release is not valid for load."
 * @require types::may_load_atomic($typeof(x)) "Only integer, float and pointers may be used."
 **/
macro @atomic_load(&x, AtomicOrdering $ordering = SEQ_CONSISTENT, $volatile = false) @builtin
{
	return $$atomic_load(&x, $volatile, (int)$ordering);
}

/**
 * @param [out] x "the variable or dereferenced pointer to store to."
 * @param value "the value to store."
 * @param $ordering "the atomic ordering of the store, defaults to SEQ_CONSISTENT"
 * @param $volatile "whether the store should be volatile, defaults to 'false'"
 *
 * @require $ordering != AtomicOrdering.ACQUIRE "Acquire ordering is not valid for store."
 * @require $ordering != AtomicOrdering.ACQUIRE_RELEASE "Acquire release is not valid for store."
 * @require types::may_load_atomic($typeof(x)) "Only integer, float and pointers may be used."
 **/
macro void @atomic_store(&x, value, AtomicOrdering $ordering = SEQ_CONSISTENT, $volatile = false) @builtin
{
	$$atomic_store(&x, value, $volatile, (int)$ordering);
}

macro compare_exchange(ptr, compare, value, AtomicOrdering $success = SEQ_CONSISTENT, AtomicOrdering $failure = SEQ_CONSISTENT, bool $volatile = true, bool $weak = false, usz $alignment = 0)
{
	return $$compare_exchange(ptr, compare, value, $volatile, $weak, $success.ordinal, $failure.ordinal, $alignment);
}

macro compare_exchange_volatile(ptr, compare, value, AtomicOrdering $success = SEQ_CONSISTENT, AtomicOrdering $failure = SEQ_CONSISTENT)
{
	return compare_exchange(ptr, compare, value, $success, $failure, true);
}

/**
 * @require math::is_power_of_2(alignment)
 **/
fn usz aligned_offset(usz offset, usz alignment)
{
	return alignment * ((offset + alignment - 1) / alignment);
}

macro void* aligned_pointer(void* ptr, usz alignment)
{
	return (void*)(uptr)aligned_offset((uptr)ptr, alignment);
}

/**
 * @require math::is_power_of_2(alignment)
 **/
fn bool ptr_is_aligned(void* ptr, usz alignment) @inline
{
	return (uptr)ptr & ((uptr)alignment - 1) == 0;
}

macro void clear(void* dst, usz len, usz $dst_align = 0, bool $is_volatile = false, bool $inlined = false)
{
	$if ($inlined)
		$$memset_inline(dst, (char)0, len, $is_volatile, $dst_align);
	$else
		$$memset(dst, (char)0, len, $is_volatile, $dst_align);
	$endif
}

macro void copy(void* dst, void* src, usz len, usz $dst_align = 0, usz $src_align = 0, bool $is_volatile = false, bool $inlined = false)
{
	$if ($inlined)
		$$memcpy_inline(dst, src, len, $is_volatile, $dst_align, $src_align);
	$else
		$$memcpy(dst, src, len, $is_volatile, $dst_align, $src_align);
	$endif
}

macro void move(void* dst, void* src, usz len, usz $dst_align = 0, usz $src_align = 0, bool $is_volatile = false)
{
	$$memmove(dst, src, len, $is_volatile, $dst_align, $src_align);
}

macro void set(void* dst, char val, usz len, usz $dst_align = 0, bool $is_volatile = false, bool $inlined = false)
{
	$if ($inlined)
		$$memset_inline(dst, val, len, $is_volatile, $dst_align);
	$else
		$$memset(dst, val, len, $is_volatile, $dst_align);
	$endif
}

/**
 * @require values::@inner_kind(a) == TypeKind.SUBARRAY || values::@inner_kind(a) == TypeKind.POINTER
 * @require values::@inner_kind(b) == TypeKind.SUBARRAY || values::@inner_kind(b) == TypeKind.POINTER
 * @require values::@inner_kind(a) != TypeKind.SUBARRAY || len == -1
 * @require values::@inner_kind(a) != TypeKind.POINTER || len > -1
 * @checked (a = b), (b = a)
 **/
macro bool equals(a, b, isz len = -1, usz $align = 0)
{
	$if (!$align)
		$align = $typeof(a[0]).alignof;
	$endif
	void* x @noinit;
	void* y @noinit;
	$if (values::@inner_kind(a) == TypeKind.SUBARRAY)
		len = a.len;
		if (len != b.len) return false;
		x = a.ptr;
		y = b.ptr;
	$else
		x = a;
		y = b;
		assert(len >= 0, "A zero or positive length must be given when comparing pointers.");
	$endif

	if (!len) return true;
	var $Type;
    $switch ($align)
		$case 1:
			$Type = char;
		$case 2:
			$Type = ushort;
		$case 4:
			$Type = uint;
		$case 8:
		$default:
			$Type = ulong;
	$endswitch
	var $step = $Type.sizeof;
	usz end = len / $step;
	for (usz i = 0; i < end; i++)
	{
		if ((($Type*)x)[i] != (($Type*)y)[i]) return false;
	}
	usz last = len % $align;
	for (usz i = len - last; i < len; i++)
	{
		if (((char*)x)[i] != ((char*)y)[i]) return false;
	}
	return true;
}

macro @clone(&value) @builtin
{
	$typeof(value)* x = malloc($typeof(value));
	*x = value;
	return x;
}

macro @tclone(&value) @builtin
{
	$typeof(value)* x = talloc($typeof(value));
	*x = value;
	return x;
}

macro type_alloc_must_be_aligned($Type)
{
	return $Type.alignof > DEFAULT_MEM_ALIGNMENT;
}
/**
 * @require $vacount > 0 && $vacount < 3 "Expected size, type, or type + len"
 * @require $vacount != 2 || $checks($vatype(0).sizeof) "Expected 'malloc(Foo, 12)'"
 **/
macro malloc(..., Allocator* using = mem::heap(), usz end_padding = 0) @builtin
{
	return malloc_checked($vasplat(), .using = using, .end_padding = end_padding)!!;
}

/**
 * @require $vacount > 0 && $vacount < 3 "Expected size, type, or type + len"
 * @require $vacount != 2 || $checks($vatype(0).sizeof) "Expected 'malloc(Foo, 12)'"
 **/
macro malloc_checked(..., Allocator* using = mem::heap(), usz end_padding = 0) @builtin
{
	$if ($checks($vatype(0).sizeof))
		var $Type = $vatype(0);
		$assert(!type_alloc_must_be_aligned($vatype(0)),  "Type must be allocated with malloc_aligned");
		$if ($vacount == 2)
			usz size = $vaarg(1);
			return (($Type*)using.alloc($Type.sizeof * size + end_padding))[:size];
		$else
			return ($Type*)using.alloc($Type.sizeof + end_padding);
		$endif
	$else
		return using.alloc($vaarg(0) + end_padding);
	$endif
}


/**
 * @require $vacount > 0 && $vacount < 3 "Expected size, type, or type + len"
 * @require $vacount != 2 || $checks($vatype(0).sizeof) "Expected 'malloc(Foo, 12)'"
 * @require alignment && math::is_power_of_2(alignment)
 **/
macro malloc_aligned(..., usz alignment = 0, usz end_padding = 0, Allocator* using = mem::heap()) @builtin
{
	$if ($checks($vatype(0).sizeof))
		var $Type = $vatype(0);
		$if ($vacount == 2)
			usz size = $vaarg(1);
			return (($Type*)using.alloc_aligned($Type.sizeof * size + end_padding, alignment))[:size];
		$else
			return ($Type*)using.alloc_aligned($Type.sizeof + end_padding, alignment);
		$endif
	$else
		return using.alloc_aligned($vaarg(0) + end_padding, alignment);
	$endif
}

/**
 * @require $vacount > 0 && $vacount < 3 "Expected size, type, or type + len"
 * @require $vacount != 2 || $checks($vatype(0).sizeof) "Expected 'malloc(Foo, 12)'"
 **/
macro calloc(..., Allocator* using = mem::heap(), usz end_padding = 0) @builtin
{
	return calloc_checked($vasplat(), .using = using, .end_padding = end_padding)!!;
}

/**
 * @require $vacount > 0 && $vacount < 3 "Expected size, type, or type + len"
 * @require $vacount != 2 || $checks($vatype(0).sizeof) "Expected 'malloc(Foo, 12)'"
 **/
macro calloc_checked(..., Allocator* using = mem::heap(), usz end_padding = 0) @builtin
{
	$if ($checks($vatype(0).sizeof))
		var $Type = $vatype(0);
		$assert(!type_alloc_must_be_aligned($vatype(0)),  "Type must be allocated with calloc_aligned");
		$if ($vacount == 2)
			usz size = $vaarg(1);
			return (($Type*)using.calloc($Type.sizeof * size + end_padding))[:size];
		$else
			return ($Type*)using.calloc($Type.sizeof + end_padding);
		$endif
	$else
		return using.calloc($vaarg(0) + end_padding);
	$endif
}


/**
 * @require $vacount > 0 && $vacount < 3 "Expected size, type, or type + len"
 * @require $vacount != 2 || $checks($vatype(0).sizeof) "Expected 'malloc(Foo, 12)'"
 * @require alignment && math::is_power_of_2(alignment)
 **/
macro calloc_aligned(..., usz alignment = 0, Allocator* using = mem::heap(), usz end_padding = 0) @builtin
{
	$if ($checks($vatype(0).sizeof))
		var $Type = $vatype(0);
		$if ($vacount == 2)
			usz size = $vaarg(1);
			return (($Type*)using.calloc_aligned($Type.sizeof * size + end_padding, alignment))[:size];
		$else
			return ($Type*)using.calloc_aligned($Type.sizeof + end_padding, alignment);
		$endif
	$else
		return using.calloc_aligned($vaarg(0) + end_padding, alignment);
	$endif
}

fn void* realloc(void *ptr, usz new_size, Allocator* using = mem::heap()) @builtin @inline
{
	return using.realloc(ptr, new_size)!!;
}

fn void*! realloc_checked(void *ptr, usz new_size, Allocator* using = mem::heap()) @builtin @inline
{
	return using.realloc(ptr, new_size);
}

/**
 * @require alignment && math::is_power_of_2(alignment)
 */
fn void*! realloc_aligned(void *ptr, usz new_size, usz alignment, Allocator* using = mem::heap()) @builtin @inline
{
	return using.realloc_aligned(ptr, new_size, alignment);
}

macro void free(void* ptr, Allocator* using = mem::heap()) @builtin => using.free(ptr)!!;
macro void! free_checked(void* ptr, Allocator* using = mem::heap()) @builtin => using.free(ptr);
macro void free_aligned(void* ptr, Allocator* using = mem::heap()) @builtin => using.free_aligned(ptr)!!;
macro void! free_aligned_checked(void* ptr, Allocator* using = mem::heap()) @builtin => using.free_aligned(ptr);

/**
 * Run with a specific allocator inside of the macro body.
 **/
macro void @scoped(Allocator* using; @body())
{
	Allocator* old_allocator = thread_allocator;
	thread_allocator = using;
	defer thread_allocator = old_allocator;
	@body();
}

/**
 * @require $vacount > 0 && $vacount < 3 "Expected size, type, or type + len"
 * @require $vacount != 2 || $checks($vatype(0).sizeof) "Expected 'malloc(Foo, 12)'"
 **/
macro tmalloc(..., usz end_padding = 0, usz alignment = DEFAULT_MEM_ALIGNMENT) @builtin
{
	$if ($checks($vatype(0).sizeof))
		var $Type = $vatype(0);
		$if ($vacount == 2)
			usz size = $vaarg(1);
			return (($Type*)temp().alloc_aligned($Type.sizeof * size + end_padding, alignment))[:size]!!;
		$else
			return ($Type*)temp().alloc_aligned($Type.sizeof + end_padding, alignment)!!;
		$endif
	$else
		return temp().alloc_aligned($vaarg(0) + end_padding, alignment)!!;
	$endif
}

/**
 * @require $vacount > 0 && $vacount < 3 "Expected size, type, or type + len"
 * @require $vacount != 2 || $checks($vatype(0).sizeof) "Expected 'malloc(Foo, 12)'"
 **/
macro tcalloc(..., usz end_padding = 0, usz alignment = mem::DEFAULT_MEM_ALIGNMENT) @builtin
{
	$if ($checks($vatype(0).sizeof))
		var $Type = $vatype(0);
		$if ($vacount == 2)
			usz size = $vaarg(1);
			return (($Type*)temp().calloc_aligned($Type.sizeof * size + end_padding, alignment))[:size]!!;
		$else
			return ($Type*)temp().calloc_aligned($Type.sizeof + end_padding, alignment)!!;
		$endif
	$else
		return temp().calloc_aligned($vaarg(0) + end_padding, alignment)!!;
	$endif
}

fn void* trealloc(void* ptr, usz size, usz alignment = mem::DEFAULT_MEM_ALIGNMENT) @builtin @inline
{
	return temp().realloc_aligned(ptr, size, alignment)!!;
}

macro void @pool(;@body) @builtin
{
	TempAllocator* allocator = temp();
	usz mark = allocator.used;
	defer allocator.reset(mark);
	@body();
}

macro void @allocating_pool(Allocator* using; @body(bool is_temp)) @builtin
{
	TempAllocator* allocator = temp();
	usz mark = allocator.used;
	bool is_temp = allocator == using;
	defer if (!is_temp) allocator.reset(mark);
	@body(is_temp);
}

tlocal Allocator* thread_allocator @private = allocator::LIBC_ALLOCATOR;
tlocal TempAllocator* thread_temp_allocator @private = null;

macro TempAllocator* temp_allocator() => temp();

macro TempAllocator* temp()
{
	if (!thread_temp_allocator)
	{
		$switch (env::MEMORY_ENV)
		$case NORMAL:
			thread_temp_allocator = allocator::new_temp(1024 * 256, thread_allocator)!!;
		$case SMALL:
			thread_temp_allocator = allocator::new_temp(1024 * 16, thread_allocator)!!;
		$case TINY:
			thread_temp_allocator = allocator::new_temp(1024 * 2, thread_allocator)!!;
		$case NONE:
			unreachable("Temp allocator must explicitly created when memory-env is set to 'none'.");
		$endswitch
	}
	return thread_temp_allocator;
}

macro Allocator* current_allocator() => thread_allocator;
macro Allocator* heap() => thread_allocator;

$if (!env::COMPILER_LIBC_AVAILABLE && env::ARCH_TYPE == ArchType.WASM32 || env::ARCH_TYPE == ArchType.WASM64)

SimpleHeapAllocator wasm_allocator @private;

extern int __heap_base;

static initialize @priority(1)
{
	allocator::wasm_memory.allocate_block(mem::DEFAULT_MEM_ALIGNMENT)!!; // Give us a valid null.
	// Check if we need to move the heap.
	uptr start = (uptr)&__heap_base;
	if (start > mem::DEFAULT_MEM_ALIGNMENT) allocator::wasm_memory.use = start;
	wasm_allocator.init(fn (x) => allocator::wasm_memory.allocate_block(x));
	thread_allocator = &wasm_allocator;
}
$endif

module std::core::mem::allocator;

const DEFAULT_SIZE_PREFIX = usz.sizeof;
const DEFAULT_SIZE_PREFIX_ALIGNMENT = usz.alignof;

const Allocator* NULL_ALLOCATOR = &_NULL_ALLOCATOR;
const Allocator* LIBC_ALLOCATOR = &_SYSTEM_ALLOCATOR;

def AllocatorFunction = fn void*!(Allocator* allocator, usz new_size, usz alignment, usz offset, void* old_pointer, AllocationKind kind);

struct Allocator
{
    AllocatorFunction function;
}

enum AllocationKind
{
    ALLOC,
    CALLOC,
    REALLOC,
    FREE,
    ALIGNED_ALLOC,
    ALIGNED_CALLOC,
    ALIGNED_REALLOC,
    ALIGNED_FREE,
    RESET,
    MARK,
}

fault AllocationFailure
{
    OUT_OF_MEMORY,
    UNSUPPORTED_OPERATION,
    CHUNK_TOO_LARGE,
}



fn void*! Allocator.alloc(Allocator* allocator, usz size) @inline
{
	return allocator.function(allocator, size, 0, 0, null, ALLOC);
}

/**
 * @require alignment && math::is_power_of_2(alignment)
 */
fn void*! Allocator.alloc_aligned(Allocator* allocator, usz size, usz alignment, usz offset = 0) @inline
{
	return allocator.function(allocator, size, alignment, offset, null, ALIGNED_ALLOC);
}

fn void*! Allocator.realloc(Allocator* allocator, void* old_pointer, usz size) @inline
{
	return allocator.function(allocator, size, 0, 0, old_pointer, REALLOC);
}

/**
 * @require alignment && math::is_power_of_2(alignment)
 */
fn void*! Allocator.realloc_aligned(Allocator* allocator, void* old_pointer, usz size, usz alignment, usz offset = 0) @inline
{
	return allocator.function(allocator, size, alignment, offset, old_pointer, ALIGNED_REALLOC);
}

fn usz! Allocator.mark(Allocator* allocator) @inline
{
	return (usz)(uptr)allocator.function(allocator, 0, 0, 0, null, MARK);
}


fn void*! Allocator.calloc(Allocator* allocator, usz size) @inline
{
	return allocator.function(allocator, size, 0, 0, null, CALLOC);
}

/**
 * @require alignment && math::is_power_of_2(alignment)
 */
fn void*! Allocator.calloc_aligned(Allocator* allocator, usz size, usz alignment, usz offset = 0) @inline
{
	return allocator.function(allocator, size, alignment, offset, null, ALIGNED_CALLOC);
}

fn void! Allocator.free(Allocator* allocator, void* old_pointer) @inline
{
	allocator.function(allocator, 0, 0, 0, old_pointer, FREE)!;
}

fn void! Allocator.free_aligned(Allocator* allocator, void* old_pointer) @inline
{
	allocator.function(allocator, 0, 0, 0, old_pointer, ALIGNED_FREE)!;
}

fn void Allocator.reset(Allocator* allocator, usz mark = 0)
{
	allocator.function(allocator, mark, 0, 0, null, RESET)!!;
}

fn usz alignment_for_allocation(usz alignment) @inline @private
{
	if (alignment < mem::DEFAULT_MEM_ALIGNMENT)
	{
		alignment = mem::DEFAULT_MEM_ALIGNMENT;
	}
	return alignment;
}

// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::runtime;

struct VirtualAny
{
    void* ptr;
    typeid type_id;
}

struct SubArrayContainer
{
    void* ptr;
    usz len;
}

def TestFn = fn void!();

struct TestRunner
{
	String[] test_names;
	TestFn[] test_fns;
	JmpBuf buf;
}

fn TestRunner test_runner_create()
{
	return TestRunner {
		.test_fns = $$TEST_FNS,
		.test_names = $$TEST_NAMES,
	};
}

import libc;

TestRunner* current_runner @private;

fn void test_panic(String message, String file, String function, uint line)
{
	io::printn("[error]");
	io::print("\n Error: ");
	io::print(message);
	io::printn();
	io::printfn("  - in %s %s:%s.\n", function, file, line);
	libc::longjmp(&current_runner.buf, 1);
}

fn bool TestRunner.run(TestRunner* runner)
{
	current_runner = runner;
	PanicFn old_panic = builtin::panic;
	defer builtin::panic = old_panic;
	builtin::panic = &test_panic;
	int tests_passed = 0;
	int tests = runner.test_names.len;
	io::printn("----- TESTS -----");
	foreach(i, String name : runner.test_names)
	{
		io::printf("Testing %s ... ", name);
		if (libc::setjmp(&runner.buf) == 0)
		{
			if (catch err = runner.test_fns[i]())
			{
				io::printn("[failed]");
				continue;
			}
			io::printn("[ok]");
			tests_passed++;
		}
	}
	io::printfn("\n%d test(s) run.\n", tests);
	io::print("Test Result: ");
	if (tests_passed < tests)
	{
		io::print("FAILED");
	}
	else
	{
		io::print("ok");
	}
	io::printfn(". %d passed, %d failed.", tests_passed, tests - tests_passed);
	return tests == tests_passed;
}

fn bool __run_default_test_runner()
{
	return test_runner_create().run();
}

$if (!env::COMPILER_LIBC_AVAILABLE && env::ARCH_TYPE == ArchType.WASM32 || env::ARCH_TYPE == ArchType.WASM64)

extern fn void __wasm_call_ctors();
fn void wasm_initialize() @extern("_initialize") @wasm
{
	// The linker synthesizes this to call constructors.
	__wasm_call_ctors();
}
$endif
module std::core::string;
import std::ascii;

def ZString = distinct inline char*;
def Char32 = uint;
def Char16 = ushort;

fault UnicodeResult
{
	INVALID_UTF8,
	INVALID_UTF16,
	CONVERSION_FAILED,
}

const uint SURROGATE_OFFSET @private = 0x10000;
const uint SURROGATE_GENERIC_MASK @private = 0xF800;
const uint SURROGATE_MASK @private = 0xFC00;
const uint SURROGATE_CODEPOINT_MASK @private = 0x03FF;
const uint SURROGATE_BITS @private = 10;
const uint SURROGATE_LOW_VALUE @private = 0xDC00;
const uint SURROGATE_HIGH_VALUE @private = 0xD800;

fault NumberConversion
{
	EMPTY_STRING,
	NEGATIVE_VALUE,
	MALFORMED_INTEGER,
	INTEGER_OVERFLOW,
	MALFORMED_FLOAT,
	FLOAT_OUT_OF_RANGE,
}

macro String printf(String fmt, ..., Allocator* using = mem::heap())
{
	@stack_mem(256; Allocator* mem)
	{
		DString str;
		str.init(.using = mem);
		str.printf(fmt, $vasplat());
		return str.copy_str(using);
	};
}

macro String tprintf(String fmt, ...)
{
	DString str;
	str.tinit();
	str.printf(fmt, $vasplat());
	return str.str();
}

macro bool char_in_set(char c, String set)
{
	foreach (ch : set) if (ch == c) return true;
	return false;
}

fn String join(String[] s, String joiner, Allocator* using = mem::heap())
{
	if (!s)
	{
		return (String)(calloc(char, 2, .using = using)[:0]);
	}

	usz total_size = joiner.len * s.len;
	foreach (String* &str : s)
	{
		total_size += str.len;
	}
	@stack_mem(256; Allocator* mem)
	{
		DString res = dstring::new_with_capacity(total_size, .using = mem);
		res.append(s[0]);
		foreach (String* &str : s[1..])
		{
			res.append(joiner);
			res.append(*str);
		}
		return res.copy_str(using);
	};
}

/**
 * @param [in] string
 * @param [in] to_trim
 **/
fn String String.trim(String string, String to_trim = "\t\n\r ")
{
	usz start = 0;
	usz len = string.len;
	while (start < len && char_in_set(string[start], to_trim)) start++;
	if (start == len) return string[:0];
	usz end = len - 1;
	while (end > start && char_in_set(string[end], to_trim)) end--;
	return string[start..end];
}

/**
 * @param [in] string
 * @param [in] needle
 **/
fn bool String.starts_with(String string, String needle)
{
	if (needle.len > string.len) return false;
	if (!needle.len) return true;
	return string[:needle.len] == needle;
}

/**
 * @param [in] string
 * @param [in] needle
 **/
fn bool String.ends_with(String string, String needle)
{
	if (needle.len > string.len) return false;
	if (!needle.len) return true;
	return string[^needle.len..] == needle;
}

/**
 * Strip the front of the string if the prefix exists.
 *
 * @param [in] string
 * @param [in] needle
 **/
fn String String.strip(String string, String needle)
{
	if (!needle.len || !string.starts_with(needle)) return string;
	return string[needle.len..];
}

/**
 * Strip the end of the string if the suffix exists.
 *
 * @param [in] string
 * @param [in] needle
 **/
fn String String.strip_end(String string, String needle)
{
	if (!needle.len || !string.ends_with(needle)) return string;
	// Note that this is the safe way if we want to support zero length.
	return string[:(string.len - needle.len)];
}


/**
 * Split a string into parts, e.g "a|b|c" split with "|" yields { "a", "b", "c" }
 *
 * @param [in] s
 * @param [in] needle
 * @param [&inout] using "The allocator, defaults to the heap allocator"
 * @param max "Max number of elements, 0 means no limit, defaults to 0"
 * @require needle.len > 0 "The needle must be at least 1 character long"
 * @ensure return.len > 0
 **/
fn String[] String.split(String s, String needle, usz max = 0, Allocator* using = mem::heap())
{
	usz capacity = 16;
	usz i = 0;
	String* holder = malloc(String, capacity, .using = using);
	bool no_more = false;
	while (!no_more)
	{
		usz! index = i == max - 1 ? SearchResult.MISSING? : s.index_of(needle);
		String res @noinit;
		if (try index)
		{
			res = s[:index];
			s = s[index + needle.len..];
		}
		else
		{
			res = s;
			no_more = true;
		}
		if (i == capacity)
		{
			capacity *= 2;
			holder = realloc(holder, String.sizeof * capacity, .using = using);
		}
		holder[i++] = res;
	}
	return holder[:i];
}

/**
 * This function is identical to String.split, but implicitly uses the
 * temporary allocator.
 *
 * @param [in] s
 * @param [in] needle
 * @param max "Max number of elements, 0 means no limit, defaults to 0"
 **/
fn String[] String.tsplit(String s, String needle, usz max = 0)
{
	return s.split(needle, max, mem::temp()) @inline;
}

fn bool String.contains(String s, String needle)
{
	return @ok(s.index_of(needle));
}

/**
 * Find the index of the first incidence of a string.
 *
 * @param [in] s
 * @param [in] needle
 * @pure
 * @ensure return < s.len
 * @require needle.len > 0 : "The needle must be len 1 or more"
 * @return "the index of the needle"
 * @return! SearchResult.MISSING "if the needle cannot be found"
 **/
fn usz! String.index_of(String s, String needle)
{
	usz match = 0;
	usz needed = needle.len;
	usz index_start = 0;
	char search = needle[0];
	foreach (usz i, char c : s)
	{
		if (c == search)
		{
			if (!match) index_start = i;
			match++;
			if (match == needed) return index_start;
			search = needle[match];
			continue;
		}
		if (match)
		{
			match = 0;
			search = needle[0];
		}
	}
	return SearchResult.MISSING?;
}

/**
 * Find the index of the last incidence of a string.
 *
 * @param [in] s
 * @param [in] needle
 * @pure
 * @ensure return < s.len
 * @require needle.len > 0 "The needle must be len 1 or more"
 * @return "the index of the needle"
 * @return! SearchResult.MISSING "if the needle cannot be found"
 **/
fn usz! String.rindex_of(String s, String needle)
{
	usz match = 0;
	usz needed = needle.len;
	usz index_start = 0;
	char search = needle[^1];
	foreach_r (usz i, char c : s)
	{
		if (c == search)
		{
			if (!match) index_start = i;
			match++;
			if (match == needed) return index_start - needle.len + 1;
			search = needle[^(match + 1)];
			continue;
		}
		if (match)
		{
			match = 0;
			search = needle[^1];
		}
	}
	return SearchResult.MISSING?;
}

fn String ZString.as_str(ZString str)
{
	return (String)((char*)str)[:str.len()];
}

fn usz ZString.char_len(ZString str)
{
	usz len = 0;
	char* ptr = (char*)str;
	while (char c = ptr++[0])
	{
		if (c & 0xC0 != 0x80) len++;
	}
	return len;
}

fn usz ZString.len(ZString str)
{
	usz len = 0;
    char* ptr = (char*)str;
    while (char c = ptr++[0]) len++;
    return len;
}


fn ZString String.zstr_copy(String s, Allocator* using = mem::heap())
{
    usz len = s.len;
    char* str = malloc(len + 1, .using = using);
    mem::copy(str, s.ptr, len);
    str[len] = 0;
    return (ZString)str;
}

fn String String.concat(String s1, String s2, Allocator* using = mem::heap())
{
    usz full_len = s1.len + s2.len;
    char* str = malloc(full_len + 1, .using = using);
    usz s1_len = s1.len;
    mem::copy(str, s1.ptr, s1_len);
    mem::copy(str + s1_len, s2.ptr, s2.len);
    str[full_len] = 0;
    return (String)str[:full_len];
}

fn String String.tconcat(String s1, String s2) => s1.concat(s2, mem::temp());


fn ZString String.zstr_tcopy(String s) => s.zstr_copy(mem::temp()) @inline;

fn String String.copy(String s, Allocator* using = mem::heap())
{
    usz len = s.len;
    char* str = malloc(len + 1, .using = using);
    mem::copy(str, s.ptr, len);
    str[len] = 0;
    return (String)str[:len];
}

fn String String.tcopy(String s) => s.copy(mem::temp()) @inline;

fn String ZString.copy(ZString z, Allocator* using = mem::heap()) => z.as_str().copy(using) @inline;
fn String ZString.tcopy(ZString z) => z.as_str().copy(mem::temp()) @inline;

/**
 * Convert an UTF-8 string to UTF-16
 * @return "The UTF-16 string as a slice, allocated using the given allocator"
 * @return! UnicodeResult.INVALID_UTF8 "If the string contained an invalid UTF-8 sequence"
 * @return! AllocationFailure "If allocation of the string fails"
 **/
fn Char16[]! String.to_utf16(String s, Allocator* using = mem::heap())
{
	usz len16 = conv::utf16len_for_utf8(s);
	Char16* data = malloc_checked(Char16, len16 + 1, .using = using)!;
	conv::utf8to16_unsafe(s, data)!;
	data[len16] = 0;
	return data[:len16];
}

fn Char32[]! String.to_utf32(String s, Allocator* using = mem::heap())
{
	usz codepoints = conv::utf8_codepoints(s);
	Char32* data = malloc_checked(Char32, codepoints + 1, .using = using)!;
	conv::utf8to32_unsafe(s, data)!;
	data[codepoints] = 0;
	return data[:codepoints];
}

fn String! from_utf32(Char32[] utf32, Allocator* using = mem::heap())
{
	usz len = conv::utf8len_for_utf32(utf32);
	char* data = malloc_checked(len + 1, .using = using)!;
	defer catch free(data, .using = using);
	conv::utf32to8_unsafe(utf32, data);
	data[len] = 0;
	return (String)data[:len];
}

fn String! from_utf16(Char16[] utf16, Allocator* using = mem::heap())
{
	usz len = conv::utf8len_for_utf16(utf16);
	char* data = malloc_checked(len + 1, .using = using)!;
	defer catch free(data, .using = using);
	conv::utf16to8_unsafe(utf16, data)!;
	data[len] = 0;
	return (String)data[:len];
}

fn String! from_zutf16(Char16* utf16_pointer, Allocator* using = mem::heap())
{
	usz utf16_len;
	while (utf16_pointer[utf16_len] != 0) utf16_len++;
	Char16[] utf16 = utf16_pointer[:utf16_len];
	return from_utf16(utf16, using);
}

fn usz String.utf8_codepoints(String s)
{
	usz len = 0;
	foreach (char c : s)
	{
		if (c & 0xC0 != 0x80) len++;
	}
	return len;
}


macro String.to_integer(String string, $Type)
{
	usz len = string.len;
	usz index = 0;
	char* ptr = string.ptr;
	while (index < len && ascii::is_blank_m(ptr[index])) index++;
	if (len == index) return NumberConversion.EMPTY_STRING?;
	bool is_negative;
	switch (string[index])
	{
		case '-':
			if ($Type.min == 0) return NumberConversion.NEGATIVE_VALUE?;
			is_negative = true;
			index++;
		case '+':
			index++;
		default:
			break;
	}
	if (len == index) return NumberConversion.MALFORMED_INTEGER?;
	$Type base = 10;
	if (string[index] == '0')
	{
		index++;
		if (index == len) return ($Type)0;
		switch (string[index])
		{
			case 'x':
			case 'X':
				base = 16;
				index++;
			case 'b':
			case 'B':
				base = 2;
				index++;
			case 'o':
			case 'O':
				base = 8;
				index++;
			default:
				break;
		}
		if (len == index) return NumberConversion.MALFORMED_INTEGER?;
	}
	$Type value = 0;
	while (index != len)
	{
		char c = {|
			char ch = string[index++];
			if (base != 16 || ch < 'A') return (char)(ch - '0');
			if (ch <= 'F') return (char)(ch - 'A');
			if (ch < 'a') return NumberConversion.MALFORMED_INTEGER?;
			if (ch > 'f') return NumberConversion.MALFORMED_INTEGER?;
			return (char)(ch - 'a');
		|}!;
		if (c >= base) return NumberConversion.MALFORMED_INTEGER?;
		value = {|
			if (is_negative)
			{
				$Type new_value = value * base - c;
				if (new_value > value) return NumberConversion.INTEGER_OVERFLOW?;
				return new_value;
			}
			$Type new_value = value * base + c;
			if (new_value < value) return NumberConversion.INTEGER_OVERFLOW?;
			return new_value;
		|}!;
	}
	return value;
}


fn Char16[]! String.to_temp_utf16(String s) => s.to_utf16(mem::temp());

fn int128! String.to_int128(String s) => s.to_integer(int128);
fn long! String.to_long(String s) => s.to_integer(long);
fn int! String.to_int(String s) => s.to_integer(int);
fn short! String.to_short(String s) => s.to_integer(short);
fn ichar! String.to_ichar(String s) => s.to_integer(ichar);

fn uint128! String.to_uint128(String s) => s.to_integer(uint128);
fn ulong! String.to_ulong(String s) => s.to_integer(ulong);
fn uint! String.to_uint(String s) => s.to_integer(uint);
fn ushort! String.to_ushort(String s) => s.to_integer(ushort);
fn char! String.to_uchar(String s) => s.to_integer(char);

fn double! String.to_double(String s) => s.to_real(double);
fn float! String.to_float(String s) => s.to_real(float);
module std::core::string::iterator;

struct StringIterator
{
	String utf8;
	usz current;
}

fn void StringIterator.reset(StringIterator* this)
{
	this.current = 0;
}

fn Char32! StringIterator.next(StringIterator* this)
{
	usz len = this.utf8.len;
	usz current = this.current;
	if (current >= len) return IteratorResult.NO_MORE_ELEMENT?;
	usz read = (len - current < 4 ? len - current : 4);
	Char32 res = conv::utf8_to_char32(&this.utf8[current], &read)!;
	this.current += read;
	return res;
}
module std::core::string;
import std::math;

// Float parsing based on code in Musl floatscan.c by Rich Felker.
// Musl uses the MIT license, copied below:
// ----------------------------------------------------------------------
//   Copyright © 2005-2014 Rich Felker, et al.
//
//   Permission is hereby granted, free of charge, to any person obtaining
//   a copy of this software and associated documentation files (the
//   "Software"), to deal in the Software without restriction, including
//   without limitation the rights to use, copy, modify, merge, publish,
//   distribute, sublicense, and/or sell copies of the Software, and to
//   permit persons to whom the Software is furnished to do so, subject to
//   the following conditions:
//
//   The above copyright notice and this permission notice shall be
//   included in all copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//   ----------------------------------------------------------------------

const KMAX = 128;
const MASK = KMAX - 1;
const B1B_DIG = 2;
const uint[2] B1B_MAX = { 9007199, 254740991 };

/**
 * @require chars.len > 0
 **/
macro double! decfloat(char[] chars, int $bits, int $emin, int sign)
{
	uint[KMAX] x;
	const uint[2] TH = B1B_MAX;
	int emax = - $emin - $bits + 3;

	const int[*] P10S = { 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000 };
	usz index;
	bool got_digit = chars[0] == '0';
	bool got_rad;
	long lrp, dc;
	int k, j, lnz;
	usz len = chars.len;
	usz last_char = len - 1;

	assert(len);

	char c @noinit;
	// Skip past first characters
	while ((c = chars[index]) == '0')
	{
		if (index == last_char) return sign * 0.0;
		index++;
	}

	if (c == '.')
	{
		got_rad = true;
		if (index == last_char)
		{
			if (!got_digit) return NumberConversion.MALFORMED_FLOAT?;
			return sign * 0.0;
		}
		if (index != last_char && (c = chars[++index]) == '0')
		{
			lrp--;
			got_digit = true;
			while (last_char != index && (c = chars[++index]) == '0')
			{
				lrp--;
			}
		}
	}

	while (c - '0' < 10u || c == '.')
	{
		switch
		{
			case c == '.':
				if (got_rad) return NumberConversion.MALFORMED_FLOAT?;
				got_rad = true;
				lrp = dc;
			case k < KMAX - 3:
				dc++;
				if (c != '0') lnz = (int)dc;
				if (j)
				{
					x[k] = x[k] * 10 + c - '0';
				}
				else
				{
					x[k] = c - '0';
				}
				if (++j == 9)
				{
					k++;
					j = 0;
				}
				got_digit = true;
			default:
				dc++;
        		if (c != '0') x[KMAX - 4] |= 1;

		}
		if (index == last_char) break;
		assert(index < last_char);
		c = chars[++index];
	}
	if (!got_rad) lrp = dc;
	if (!got_digit) return NumberConversion.MALFORMED_FLOAT?;
	if ((c | 32) == 'e')
	{
		if (last_char == index) return NumberConversion.MALFORMED_FLOAT?;
		long e10 = String.to_long((String)chars[index + 1..]) ?? NumberConversion.MALFORMED_FLOAT? !s : d;
		lrp += e10;
	}
	else if (index != last_char)
	{
		return NumberConversion.MALFORMED_FLOAT?;
	}
	// Handle zero specially to avoid nasty special cases later
	if (!x[0]) return sign * 0.0;

	// Optimize small integers (w/no exponent) and over/under-flow
	if (lrp == dc && dc < 10 && ($bits > 30 || (ulong)x[0] >> $bits == 0)) return sign * (double)x[0];
	if (lrp > - $emin / 2) return NumberConversion.FLOAT_OUT_OF_RANGE?;
	if (lrp < $emin - 2 * math::DOUBLE_MANT_DIG) return NumberConversion.FLOAT_OUT_OF_RANGE?;

	// Align incomplete final B1B digit
	if (j)
	{
		for (; j < 9; j++) x[k] *= 10;
		k++;
		j = 0;
	}

	int a;
	int z = k;
	int e2;
	long rp = lrp;

	// Optimize small to mid-size integers (even in exp. notation)
	if (lnz < 9 && lnz <= rp && rp < 18)
	{
		if (rp == 9) return sign * (double)x[0];
		if (rp < 9) return sign * (double)x[0] / P10S[8 - rp];
		int bitlim = $bits - 3 * (int)(rp - 9);
		if (bitlim > 30 || x[0] >> bitlim == 0) return sign * (double)x[0] * P10S[rp - 10];
	}

	// Align radix point to B1B digit boundary
	if (rp % 9)
	{
		long rpm9 = rp >= 0 ? rp % 9 : rp % 9 + 9;
		int p10 = P10S[8 - rpm9];
		uint carry = 0;
		for (k = a; k != z; k++)
		{
			uint tmp = x[k] % p10;
			x[k] = x[k] / p10 + carry;
			carry = 1000000000 / p10 * tmp;
			if (k == a && !x[k])
			{
				a = (a + 1) & MASK;
				rp -= 9;
			}
		}
		if (carry) x[z++] = carry;
		rp += 9 - rpm9;
	}

	// Upscale until desired number of bits are left of radix point
	while (rp < 9 * B1B_DIG || (rp == 9 * B1B_DIG && x[a] < TH[0]))
	{
		uint carry = 0;
		e2 -= 29;
		for (k = (z - 1) & MASK; ; k = (k - 1) & MASK)
		{
			ulong tmp = (ulong)x[k] << 29 + carry;
			if (tmp > 1000000000)
			{
				carry = (uint)(tmp / 1000000000);
				x[k] = (uint)(tmp % 1000000000);
			}
			else
			{
				carry = 0;
				x[k] = (uint)tmp;
			}
			if (k == (z - 1) & MASK && k != a && !x[k]) z = k;
			if (k == a) break;
		}
		if (carry)
		{
			rp += 9;
			a = (a - 1) & MASK;
			if (a == z)
			{
				z = (z - 1) & MASK;
				x[(z - 1) & MASK] |= x[z];
			}
			x[a] = carry;
		}
	}

	// Downscale until exactly number of bits are left of radix point
	while (true)
	{
		uint carry = 0;
		int sh = 1;
		int i;
		for (i = 0; i < B1B_DIG; i++)
		{
			k = (a + i) & MASK;
			if (k == z || x[k] < TH[i])
			{
				i = B1B_DIG;
				break;
			}
			if (x[(a + i) & MASK] > TH[i]) break;
		}
		if (i == B1B_DIG && rp == 9 * B1B_DIG) break;
		if (rp > 9 + 9 * B1B_DIG) sh = 9;
		e2 += sh;
		for (k = a; k != z; k = (k+1) & MASK)
		{
			uint tmp = x[k] & (1 << sh - 1);
			x[k] = x[k] >> sh + carry;
			carry = (1000000000 >> sh) * tmp;
			if (k == a && !x[k])
			{
			 	a = (a + 1) & MASK;
				i--;
				rp -= 9;
			}
		}
		if (carry)
		{
			if ((z + 1) & MASK != a)
			{
				x[z] = carry;
				z = (z + 1) & MASK;
			}
			else
			{
				x[(z - 1) & MASK] |= 1;
			}
		}
	}

	// Assemble desired bits into floating point variable
	double y;
	int i;
	for (i = 0; i < B1B_DIG; i++)
	{
		if ((a + i) & MASK == z) x[(z = (z + 1) & MASK) - 1] = 0;
		y = 1000000000.0 * y + x[(a + i) & MASK];
	}

	y *= sign;

	bool denormal;
	/* Limit precision for denormal results */
	uint bits = $bits;
	if (bits > math::DOUBLE_MANT_DIG + e2 - $emin)
	{
		bits = math::DOUBLE_MANT_DIG + e2 - $emin;
		if (bits < 0) bits = 0;
		denormal = true;
	}

	// Calculate bias term to force rounding, move out lower bits
	double bias;
	double frac;
	if (bits < math::DOUBLE_MANT_DIG)
	{
		bias = math::copysign(math::scalbn(1, 2 * math::DOUBLE_MANT_DIG - bits - 1), y);
		frac = y % math::scalbn(1, math::DOUBLE_MANT_DIG - bits);
		y -= frac;
		y += bias;
	}

	// Process tail of decimal input so it can affect rounding
	if ((a + i) & MASK != z)
	{
		uint t = x[(a + i) & MASK];
		switch
		{
			case t < 500000000 && (t || (a + i + 1) & MASK != z):
				frac += 0.25 * sign;
			case t > 500000000:
				frac += 0.75 * sign;
			case t == 500000000:
				if ((a + i + 1) & MASK == z)
				{
					frac += 0.5 * sign;
				}
				else
				{
					frac += 0.75 * sign;
				}
		}
		if (math::DOUBLE_MANT_DIG - bits >= 2 && !(frac % 1)) frac++;
	}

	y += frac;
	y -= bias;

	if (((e2 + math::DOUBLE_MANT_DIG) & int.max) > emax - 5)
	{
		if (math::abs(y) >= 0x1p53)
		{
			if (denormal && bits == math::DOUBLE_MANT_DIG + e2 - $emin) denormal = false;
			y *= 0.5;
			e2++;
		}
		if (e2 + math::DOUBLE_MANT_DIG > emax || (denormal && frac)) return NumberConversion.MALFORMED_FLOAT?;
	}
	return math::scalbn(y, e2);
}

macro double! hexfloat(char[] chars, int $bits, int $emin, int sign)
{
	double scale = 1;
	uint x;
	long rp;
	long dc;
	char c @noinit;
	bool got_rad;
	bool got_digit;
	bool got_tail;
	usz len = chars.len;
	usz last_char = len - 1;
	usz index;
	double y;

	// Skip past first characters
	while ((c = chars[index]) == '0')
	{
		if (index == last_char) return 0.0;
		index++;
	}
	if (c == '.')
	{
		got_rad = true;
		if (index == last_char)
		{
			if (!got_digit) return NumberConversion.MALFORMED_FLOAT?;
			return sign * 0.0;
		}
		if (index != last_char && (c = chars[++index]) == '0')
		{
			rp--;
			got_digit = true;
			while (last_char != index && (c = chars[++index]) == '0')
			{
				rp--;
			}
		}
	}

	while ((c - '0') < 10u || ((c | 32) - 'a') < 6u || c == '.')
	{
		if (c == '.')
		{
			if (got_rad) return NumberConversion.MALFORMED_FLOAT?;
			got_rad = true;
			rp = dc;
		}
		else
		{
			got_digit = true;
			int d = {|
				if (c > '9') return (c | 32) + 10 - 'a';
				return c - '0';
			|};
			switch
			{
				case dc < 8:
					x = x * 16 + d;
				case dc < math::DOUBLE_MANT_DIG / 4 + 1:
					y += d * (scale /= 16);
					got_tail = true;
				case d && !got_tail:
					y += 0.5 * scale;
					got_tail = true;
			}
			dc++;
		}
		if (index == last_char) break;
		c = chars[++index];
	}
	if (!got_digit) return NumberConversion.MALFORMED_FLOAT?;
	if (!got_rad) rp = dc;
	for (; dc < 8; dc++) x *= 16;

	long e2;
	if ((c | 32) == 'p')
	{
		long e2val = String.to_long((String)chars[index + 1..]) ?? (NumberConversion.MALFORMED_FLOAT?)!;
    	e2 = e2val;
	}
	e2 += 4 * rp - 32;
	if (!x) return sign * 0.0;
	if (e2 > -$emin) return NumberConversion.FLOAT_OUT_OF_RANGE?;
	if (e2 < $emin - 2 * math::DOUBLE_MANT_DIG) return NumberConversion.FLOAT_OUT_OF_RANGE?;

	while (x < 0x80000000)
	{
		if (y >= 0.5)
		{
			x += x + 1;
			y += y - 1;
		}
		else
		{
			x += x;
			y += y;
		}
		e2--;
	}
	int bits = $bits;
	if ($bits > 32 + e2 - $emin)
	{
		bits = (int)(32 + e2 - $emin);
		if (bits < 0) bits = 0;
	}
	double bias;
	if (bits < math::DOUBLE_MANT_DIG)
	{
		bias = math::copysign(math::scalbn(1, 32 + math::DOUBLE_MANT_DIG - bits - 1), (double)sign);
	}

	if (bits < 32 && y && !(x & 1))
	{
		x++;
		y = 0;
	}
	y = bias + sign * (double)x + sign * y;
	y -= bias;
	if (!y) return NumberConversion.FLOAT_OUT_OF_RANGE?;

	return math::scalbn(y, (int)e2);
}

macro String.to_real(String chars, $Type) @private
{
	int sign = 1;
	$switch ($Type)
	$case float:
		const int BITS = math::FLOAT_MANT_DIG;
		const int EMIN = math::FLOAT_MIN_EXP - BITS;
	$case double:
		const int BITS = math::DOUBLE_MANT_DIG;
		const int EMIN = math::DOUBLE_MIN_EXP - BITS;
	$case float128:
		$assert(false, "Not yet supported");
	$default:
		$assert(false, "Unexpected type");
	$endswitch

 	while (chars.len && chars[0] == ' ') chars = chars[1..];
 	if (!chars.len) return NumberConversion.MALFORMED_FLOAT?;
 	switch (chars[0])
 	{
 	    case '-':
 	        sign = -1;
 	        nextcase;
 	    case '+':
 	        chars = chars[1..];
 	}
 	if (chars == "infinity" || chars == "INFINITY") return sign * $Type.inf;
 	if (chars == "NAN" || chars == "nan") return $Type.nan;

	if (chars.len > 2 && chars[0] == '0' && (chars[1] | 32) == 'x')
	{
		return ($Type)hexfloat((char[])chars[2..], BITS, EMIN, sign);
	}
	return ($Type)decfloat((char[])chars, BITS, EMIN, sign);
}


module std::core::types;
import libc;


fault ConversionResult
{
	VALUE_OUT_OF_RANGE,
	VALUE_OUT_OF_UNSIGNED_RANGE,
}
/**
 * @require $Type.kindof.is_int() || $Type.kindof == TypeKind.ENUM "Argument was not an integer"
 **/
macro any_to_int(any v, $Type)
{
	typeid any_type = v.type;
	TypeKind kind = any_type.kindof;
	if (kind == TypeKind.ENUM)
	{
		any_type = any_type.inner;
		kind = any_type.kindof;
	}
	bool is_mixed_signed = $Type.kindof != any_type.kindof;
	$Type max = $Type.max;
	$Type min = $Type.min;
	switch (any_type)
	{
		case ichar:
			ichar c = *(char*)v.ptr;
			if (is_mixed_signed && c < 0) return ConversionResult.VALUE_OUT_OF_UNSIGNED_RANGE?;
			return ($Type)c;
		case short:
			short s = *(short*)v.ptr;
			if (is_mixed_signed && s < 0) return ConversionResult.VALUE_OUT_OF_UNSIGNED_RANGE?;
			if (s > max || s < min) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)s;
		case int:
			int i = *(int*)v.ptr;
			if (is_mixed_signed && i < 0) return ConversionResult.VALUE_OUT_OF_UNSIGNED_RANGE?;
			if (i > max || i < min) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)i;
		case long:
			long l = *(long*)v.ptr;
			if (is_mixed_signed && l < 0) return ConversionResult.VALUE_OUT_OF_UNSIGNED_RANGE?;
			if (l > max || l < min) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)l;
		case int128:
			int128 i = *(int128*)v.ptr;
			if (is_mixed_signed && i < 0) return ConversionResult.VALUE_OUT_OF_UNSIGNED_RANGE?;
			if (i > max || i < min) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)i;
		case char:
			char c = *(char*)v.ptr;
			if (c > max) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)c;
		case ushort:
			ushort s = *(ushort*)v.ptr;
			if (s > max || s < min) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)s;
		case uint:
			uint i = *(uint*)v.ptr;
			if (i > max || i < min) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)i;
		case ulong:
			ulong l = *(ulong*)v.ptr;
			if (l > max || l < min) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)l;
		case uint128:
			uint128 i = *(uint128*)v.ptr;
			if (i > max || i < min) return ConversionResult.VALUE_OUT_OF_RANGE?;
			return ($Type)i;
		default:
			unreachable();
	}
}

macro bool is_numerical($Type)
{
	var $kind = $Type.kindof;
	$if ($kind == TypeKind.DISTINCT)
		return is_numerical($Type.inner);
	$else
		return $kind == TypeKind.SIGNED_INT || $kind == TypeKind.UNSIGNED_INT || $kind == TypeKind.FLOAT
			|| $kind == TypeKind.VECTOR;
	$endif
}

fn bool TypeKind.is_int(TypeKind kind) @inline
{
	return kind == TypeKind.SIGNED_INT || kind == TypeKind.UNSIGNED_INT;
}

macro bool is_indexable($Type)
{
	return $checks($Type t, int i, t[i]);
}

macro bool is_comparable($Type)
{
	var $kind = $Type.kindof;
	$if ($kind == TypeKind.DISTINCT)
		return is_comparable($Type.inner);
	$else
		return $kind == TypeKind.SIGNED_INT || $kind == TypeKind.UNSIGNED_INT || $kind == TypeKind.FLOAT
			|| $kind == TypeKind.VECTOR || $kind == TypeKind.BOOL || $kind == TypeKind.POINTER
			|| $kind == TypeKind.ENUM;
	$endif
}

macro bool is_equatable($Type)
{
	return $checks($Type a, a == a);
}

macro bool is_subarray_convertable($Type)
{
	$switch ($Type.kindof)
		$case SUBARRAY:
			return true;
		$case POINTER:
			return $Type.inner.kindof == TypeKind.ARRAY;
		$default:
			return false;
	$endswitch
}

macro bool is_bool($Type) => $Type.kindof == TypeKind.BOOL;
macro bool is_int($Type) => $Type.kindof == TypeKind.SIGNED_INT || $Type.kindof == TypeKind.UNSIGNED_INT;

macro bool is_intlike($Type)
{
	$switch ($Type.kindof)
		$case SIGNED_INT:
		$case UNSIGNED_INT:
			return true;
		$case VECTOR:
			return $Type.inner.kindof == TypeKind.SIGNED_INT || $Type.inner.kindof == TypeKind.UNSIGNED_INT;
		$default:
			return false;
	$endswitch
}


macro bool is_float($Type) => $Type.kindof == TypeKind.FLOAT;

macro bool is_floatlike($Type)
{
	$switch ($Type.kindof)
		$case FLOAT:
			return true;
		$case VECTOR:
			return $Type.inner.kindof == TypeKind.FLOAT;
		$default:
			return false;
	$endswitch
}

macro bool is_vector($Type)
{
	return $Type.kindof == TypeKind.VECTOR;
}

macro TypeKind inner_kind($Type)
{
	$if ($Type.kindof == TypeKind.DISTINCT)
		return inner_kind($typefrom($Type.inner));
	$else
		return $Type.kindof;
	$endif
}

macro bool @convertable(#a, $TypeB) @builtin
{
	return $checks($TypeB x = #a);
}

macro bool is_same($TypeA, $TypeB)
{
	return $TypeA.typeid == $TypeB.typeid;
}

macro bool @has_same(#a, #b, ...)
{
	var $type_a = $typeof(#a).typeid;
	$if ($type_a != $typeof(#b).typeid)
	    return false;
	$endif
	$for (var $i = 0; $i < $vacount; $i++)
		$if ($typeof($vaexpr($i)).typeid != $type_a)
			return false;
		$endif
	$endfor
	return true;
}

macro bool may_load_atomic($Type)
{
	$switch ($Type.kindof)
	$case SIGNED_INT:
	$case UNSIGNED_INT:
	$case POINTER:
	$case FLOAT:
		return true;
	$case DISTINCT:
		return may_load_atomic($Type.inner);
	$default:
		return false;
	$endswitch
}

macro bool is_promotable_to_floatlike($Type) => types::is_floatlike($Type) || types::is_int($Type);
macro bool is_promotable_to_float($Type) => types::is_float($Type) || types::is_int($Type);

macro bool is_same_vector_type($Type1, $Type2)
{
	$if ($Type1.kindof != TypeKind.VECTOR)
		return $Type2.kindof != TypeKind.VECTOR;
	$else
		return $Type1.inner == $Type2.inner && $Type1.len == $Type2.len;
	$endif
}

macro bool is_equatable_type($Type)
{
	$if ($defined($Type.less) || $defined($Type.compare_to) || $defined($Type.equals))
		return true;
	$else
		return is_equatable($Type);
	$endif
}

macro bool is_equatable_value(value)
{
	return is_equatable_type($typeof(value));
}

macro bool is_comparable_value(value)
{
	$if ($defined(value.less) || $defined(value.compare_to))
		return true;
	$else
		return is_comparable($typeof(value));
	$endif
}

enum TypeKind : char
{
    VOID,
    BOOL,
    SIGNED_INT,
    UNSIGNED_INT,
    FLOAT,
    TYPEID,
    ANYFAULT,
    ANY,
    ENUM,
    FAULT,
    STRUCT,
    UNION,
    BITSTRUCT,
    FUNC,
    OPTIONAL,
    ARRAY,
    SUBARRAY,
    VECTOR,
    DISTINCT,
    POINTER,
}

struct TypeEnum
{
	TypeKind type;
	usz elements;
}
module std::core::values;

macro TypeKind @typekind(#value) @builtin => $typeof(#value).kindof;
macro bool @typeis(#value, $Type) @builtin => $typeof(#value).typeid == $Type.typeid;
macro bool @is_bool(#value) => types::is_bool($typeof(#value));
macro bool @is_int(#value) => types::is_int($typeof(#value));
macro bool @convertable_to(#a, #b) => $checks($typeof(#b) x = #a);
macro bool @is_floatlike(#value) => types::is_floatlike($typeof(#value));
macro bool @is_float(#value) => types::is_float($typeof(#value));
macro bool @is_promotable_to_floatlike(#value) => types::is_promotable_to_floatlike($typeof(#value));
macro bool @is_promotable_to_float(#value) => types::is_promotable_to_float($typeof(#value));
macro bool @is_same_vector_type(#value1, #value2) => types::is_same_vector_type($typeof(#value1), $typeof(#value2));
macro promote_int(x)
{
	$if (@is_int(x))
		return (double)x;
	$else
		return x;
	$endif
}

macro TypeKind @inner_kind(#value) => types::inner_kind($typeof(#value));

module std::crypto::rc4;
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.

struct Rc4
{
	uint i, j;
	char[256] state;
}

/**
 * Initialize the RC4 state.
 *
 * @param [inout] this "The RC4 state"
 * @param [in] key "The key to use"
 * @require key.len > 0 "The key must be at least 1 byte long"
 **/
fn void Rc4.init(Rc4* this, char[] key)
{
	// Init the state matrix
	foreach (char i, &c : this.state) *c = i;
	for (int i = 0, int j = 0; i < 256; i++)
	{
		j = (j + this.state[i] + key[i % key.len]) & 0xFF;
		@swap(this.state[i], this.state[j]);
	}
	this.i = 0;
	this.j = 0;
}

/**
 * Encrypt or decrypt a sequence of bytes.
 *
 * @param [inout] this "The RC4 State"
 * @param [in] in "The input"
 * @param [out] out "The output"
 * @require in.len <= out.len "Output would overflow"
 **/
fn void Rc4.crypt(Rc4* this, char[] in, char[] out)
{
	uint i = this.i;
	uint j = this.j;
	char* state = &this.state;
	isz len = in.len;
	foreach (idx, c : in)
	{
		i = (i + 1) & 0xFF;
		j = (j + state[i]) & 0xFF;
		@swap(state[i], state[j]);
		out[idx] = in[idx] ^ state[(state[i] + state[j]) & 0xFF];
	}
	this.i = i;
	this.j = j;
}

/**
 * Clear the rc4 state.
 *
 * @param [out] this "The RC4 State"
 **/
fn void Rc4.destroy(Rc4* this)
{
	*this = {};
}

// Copyright (c) 2023 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::encoding::json;
import std::io;
import std::ascii;
import std::collections::object;

enum JsonTokenType
{
	NO_TOKEN,
	LBRACE,
	LBRACKET,
	COMMA,
	COLON,
	RBRACE,
	RBRACKET,
	STRING,
	NUMBER,
	TRUE,
	FALSE,
	NULL,
	EOF,
}

struct JsonParser
{
	uint line;
	Stream stream;
	Allocator* allocator;
	JsonTokenType token;
	DString last_string;
	double last_number;
	char current;
	anyfault current_err;
	bool skip_comments;
	bool reached_end;
}

fault JsonParsingError
{
	EOF,
	UNEXPECTED_CHARACTER,
	INVALID_ESCAPE_SEQUENCE,
	DUPLICATE_MEMBERS,
	INVALID_NUMBER,
}

fn void JsonParser.init(JsonParser* parser, Stream s, Allocator* using = mem::heap())
{
	*parser = { .last_string = dstring::new_with_capacity(64, using), .stream = s, .allocator = using };
}

fn Object*! JsonParser.parse_from_token(JsonParser* this, JsonTokenType token)
{
	switch (token)
	{
		case NO_TOKEN: unreachable();
		case LBRACE: return this.parse_map();
		case LBRACKET: return this.parse_array();
		case COMMA:
		case RBRACE:
		case RBRACKET:
		case COLON: return JsonParsingError.UNEXPECTED_CHARACTER?;
		case STRING: return object::new_string(this.last_string.str(), this.allocator);
		case NUMBER: return object::new_float(this.last_number, this.allocator);
		case TRUE: return object::new_bool(true);
		case FALSE: return object::new_bool(false);
		case NULL: return object::new_null();
		case EOF: return JsonParsingError.EOF?;
	}
	unreachable();
}
fn Object*! JsonParser.parse_any(JsonParser* this)
{
	return this.parse_from_token(this.advance());
}

fn JsonTokenType! JsonParser.lex_number(JsonParser* this, char c)
{
	@pool()
	{
		DString t = dstring::tnew_with_capacity(32);
		bool negate = c == '-';
		if (negate)
		{
			t.append(c);
			c = this.read_next()!;
		}
		while (c >= '0' && c <= '9')
		{
			t.append(c);
			c = this.read_next()!;
		}
		if (c == '.')
		{
			t.append(c);
			while (c = this.read_next()!, c >= '0' && c <= '9')
			{
				t.append(c);
			}
		}
		if ((c | 32) == 'e')
		{
			t.append(c);
			c = this.read_next()!;
			switch (c)
			{
				case '-':
				case '+':
					t.append(c);
					c = this.read_next()!;
			}
			if (c < '0' || c > '9') return JsonParsingError.INVALID_NUMBER?;
			while (c >= '0' && c <= '9')
			{
				t.append(c);
				c = this.read_next()!;
			}
		}
		this.pushback();
		double! d = t.str().to_double() ?? JsonParsingError.INVALID_NUMBER?;
		this.last_number = d!;
		return NUMBER;
	};
}

fn Object*! JsonParser.parse_map(JsonParser* this)
{
	Object* map = object::new_obj(this.allocator);
	JsonTokenType token = this.advance()!;
	defer catch map.free();

	DString temp_key = dstring::new_with_capacity(32, this.allocator);
	defer temp_key.free();
	while (token != JsonTokenType.RBRACE)
	{
		if (token != JsonTokenType.STRING) return JsonParsingError.UNEXPECTED_CHARACTER?;
        DString string = this.last_string;
        if (map.has_key(string.str())) return JsonParsingError.DUPLICATE_MEMBERS?;
        // Copy the key to our temp holder. We do this to work around the issue
        // if the temp allocator should be used as the default allocator.
        temp_key.clear();
        temp_key.append(string);
        this.parse_expected(COLON)!;
        Object* element = this.parse_any()!;
		map.set(temp_key.str(), element);
        token = this.advance()!;
        if (token == JsonTokenType.COMMA)
        {
            token = this.advance()!;
            continue;
        }
        if (token != JsonTokenType.RBRACE) return JsonParsingError.UNEXPECTED_CHARACTER?;
	}
	return map;
}

fn Object*! JsonParser.parse_array(JsonParser* this)
{
	Object* list = object::new_obj(this.allocator);
	defer catch list.free();
	JsonTokenType token = this.advance()!;
	while (token != JsonTokenType.RBRACKET)
	{
		Object* element = this.parse_from_token(token)!;
		list.append(element);
		token = this.advance()!;
		if (token == JsonTokenType.COMMA)
		{
			token = this.advance()!;
		    continue;
		}
		if (token != JsonTokenType.RBRACKET) return JsonParsingError.UNEXPECTED_CHARACTER?;
	}
	return list;
}

fn void JsonParser.pushback(JsonParser* this)
{
	if (!this.reached_end) this.stream.pushback_byte()!!;
}

fn char! JsonParser.read_next(JsonParser* this)
{
	if (this.reached_end) return '\0';
	char! c = this.stream.read_byte();
	if (catch err = c)
	{
		case IoError.EOF:
			this.reached_end = true;
			return '\0';
		default:
			return err?;
	}
	if (c == 0)
	{
		this.reached_end = true;
	}
	return c;
}

fn JsonTokenType! JsonParser.advance(JsonParser* this)
{
	char c;
	// Skip whitespace
	while WS: (c = this.read_next()!)
	{
		switch (c)
		{
			case '\n':
				this.line++;
				nextcase;
			case ' ':
			case '\t':
			case '\r':
			case '\v':
				continue;
			case '/':
				if (!this.skip_comments) break;
				c = this.read_next()!;
				if (c != '*')
				{
					this.pushback();
					break WS;
				}
				while COMMENT: (1)
				{
					// Skip to */
					while (c = this.read_next()!)
					{
						if (c == '\n') this.line++;
						if (c != '*') continue;
						// Skip through all the '*'
						while (c = this.read_next()!)
						{
							if (c == '\n') this.line++;
							if (c != '*') break;
						}
						if (c == '/') break COMMENT;
					}
				}
				continue;
			default:
				break WS;
		}
	}
	switch (c)
	{
		case '\0':
			return IoError.EOF?;
		case '{':
			return LBRACE;
		case '}':
			return RBRACE;
		case '[':
			return LBRACKET;
		case ']':
			return RBRACKET;
		case ':':
			return COLON;
		case ',':
			return COMMA;
		case '"':
			return this.lex_string();
		case '-':
		case '0'..'9':
			return this.lex_number(c);
		case 't':
			this.match("rue")!;
			return TRUE;
		case 'f':
			this.match("alse")!;
			return FALSE;
		case 'n':
			this.match("ull")!;
			return NULL;
		default:
			return JsonParsingError.UNEXPECTED_CHARACTER?;
	}
}

fn void! JsonParser.match(JsonParser* this, String str)
{
	foreach (c : str)
	{
		char l = this.read_next()!;
		if (l != c) return JsonParsingError.UNEXPECTED_CHARACTER?;
	}
}

fn void! JsonParser.parse_expected(JsonParser* this, JsonTokenType token) @local
{
	if (this.advance()! != token) return JsonParsingError.UNEXPECTED_CHARACTER?;
}

fn JsonTokenType! JsonParser.lex_string(JsonParser *this)
{
	this.last_string.clear();
	while LOOP: (1)
	{
		char c = this.read_next()!;
		switch (c)
		{
			case '\0':
				return JsonParsingError.EOF?;
			case 1..31:
				return JsonParsingError.UNEXPECTED_CHARACTER?;
			case '"':
				break LOOP;
			case '\\':
				break;
			default:
				this.last_string.append(c);
				continue;
		}
		c = this.read_next()!;
		switch (c)
		{
			case '\0':
				return JsonParsingError.EOF?;
			case 1..31:
				return JsonParsingError.UNEXPECTED_CHARACTER?;
			case '"':
			case '\\':
			case '/':
				break;
			case 'b':
				c = '\b';
			case 'f':
				c = '\f';
			case 'n':
				c = '\n';
			case 'r':
				c = '\r';
			case 't':
				c = '\t';
			case 'u':
				uint val;
				for (int i = 0; i < 4; i++)
				{
					c = this.read_next()!;
					if (!c.is_xdigit()) return JsonParsingError.INVALID_ESCAPE_SEQUENCE?;
					val = val << 4 + (c > '9' ? (c | 32) - 'a' + 10 : c - '0');
				}
				this.last_string.append_char32(val);
				continue;
			default:
				 return JsonParsingError.INVALID_ESCAPE_SEQUENCE?;
		}
	}
	return STRING;
}
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.

module std::hash::adler32;

const uint ADLER_CONST @private = 65521;

struct Adler32
{
    uint a;
    uint b;
}

fn void Adler32.init(Adler32 *this)
{
    *this = { 1, 0 };
}

fn void Adler32.updatec(Adler32* this, char c)
{
    this.a = (this.a + c) % ADLER_CONST;
    this.b = (this.b + this.a) % ADLER_CONST;
}

fn void Adler32.update(Adler32* this, char[] data)
{
    uint a = this.a;
    uint b = this.b;
    foreach (char x : data)
    {
        a = (a + x) % ADLER_CONST;
        b = (b + a) % ADLER_CONST;
    }
    *this = { a, b };
}

fn uint Adler32.final(Adler32* this)
{
    return (this.b << 16) | this.a;
}

fn uint encode(char[] data)
{
    uint a = 1;
    uint b = 0;
    foreach (char x : data)
    {
        a = (a + x) % ADLER_CONST;
        b = (b + a) % ADLER_CONST;
    }
    return (b << 16) | a;
}
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::hash::crc32;

struct Crc32
{
    uint result;
}

fn void Crc32.init(Crc32* this, uint seed = 0)
{
    this.result = ~seed;
}

fn void Crc32.updatec(Crc32* this, char c)
{
    this.result = (this.result >> 8) ^ CRC32_TABLE[(this.result ^ c) & 0xFF];
}

fn void Crc32.update(Crc32* this, char[] data)
{
    uint result = this.result;
    foreach (char x : data)
    {
        result = (result >> 8) ^ CRC32_TABLE[(result ^ x) & 0xFF];
    }
    this.result = result;
}

fn uint Crc32.final(Crc32* this)
{
    return ~this.result;
}

fn uint encode(char[] data)
{
    uint result = ~(uint)(0);
    foreach (char x : data)
    {
        result = (result >> 8) ^ CRC32_TABLE[(result ^ x) & 0xFF];
    }
	return ~result;
}

const uint[256] CRC32_TABLE @private = {
	0x00000000, 0x77073096, 0xee0e612c, 0x990951ba,
	0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
	0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
	0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
	0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de,
	0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
	0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,
	0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
	0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
	0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
	0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940,
	0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
	0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116,
	0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
	0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
	0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
	0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a,
	0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
	0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818,
	0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
	0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
	0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
	0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c,
	0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
	0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2,
	0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
	0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
	0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
	0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086,
	0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
	0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4,
	0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
	0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
	0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
	0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8,
	0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
	0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe,
	0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
	0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
	0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
	0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252,
	0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
	0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60,
	0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
	0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
	0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
	0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04,
	0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
	0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a,
	0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
	0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
	0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
	0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e,
	0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
	0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c,
	0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
	0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
	0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
	0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0,
	0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
	0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6,
	0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
	0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
	0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d,
};
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::hash::crc64;

struct Crc64
{
    ulong result;
}

fn void Crc64.init(Crc64* this, uint seed = 0)
{
    this.result = seed;
}

fn void Crc64.updatec(Crc64* this, char c)
{
    this.result = (this.result << 8) ^ CRC64_TABLE[(char)((this.result >> 56) ^ c)];
}

fn void Crc64.update(Crc64* this, char[] data)
{
    ulong result = this.result;
    foreach (char x : data)
    {
        result = (result << 8) ^ CRC64_TABLE[(char)((result >> 56) ^ x)];
    }
    this.result = result;
}

fn ulong Crc64.final(Crc64* this)
{
    return this.result;
}

fn ulong encode(char[] data)
{
    ulong result = (ulong)(0);
    foreach (char x : data)
    {
        result = (result << 8) ^ CRC64_TABLE[(char)((result >> 56) ^ x)];
    }
	return result;
}

const ulong[256] CRC64_TABLE @private = {
    0x0000000000000000, 0x42f0e1eba9ea3693, 0x85e1c3d753d46d26, 0xc711223cfa3e5bb5,
   	0x493366450e42ecdf, 0x0bc387aea7a8da4c, 0xccd2a5925d9681f9, 0x8e224479f47cb76a,
   	0x9266cc8a1c85d9be, 0xd0962d61b56fef2d, 0x17870f5d4f51b498, 0x5577eeb6e6bb820b,
   	0xdb55aacf12c73561, 0x99a54b24bb2d03f2, 0x5eb4691841135847, 0x1c4488f3e8f96ed4,
   	0x663d78ff90e185ef, 0x24cd9914390bb37c, 0xe3dcbb28c335e8c9, 0xa12c5ac36adfde5a,
   	0x2f0e1eba9ea36930, 0x6dfeff5137495fa3, 0xaaefdd6dcd770416, 0xe81f3c86649d3285,
   	0xf45bb4758c645c51, 0xb6ab559e258e6ac2, 0x71ba77a2dfb03177, 0x334a9649765a07e4,
   	0xbd68d2308226b08e, 0xff9833db2bcc861d, 0x388911e7d1f2dda8, 0x7a79f00c7818eb3b,
   	0xcc7af1ff21c30bde, 0x8e8a101488293d4d, 0x499b3228721766f8, 0x0b6bd3c3dbfd506b,
   	0x854997ba2f81e701, 0xc7b97651866bd192, 0x00a8546d7c558a27, 0x4258b586d5bfbcb4,
   	0x5e1c3d753d46d260, 0x1cecdc9e94ace4f3, 0xdbfdfea26e92bf46, 0x990d1f49c77889d5,
   	0x172f5b3033043ebf, 0x55dfbadb9aee082c, 0x92ce98e760d05399, 0xd03e790cc93a650a,
   	0xaa478900b1228e31, 0xe8b768eb18c8b8a2, 0x2fa64ad7e2f6e317, 0x6d56ab3c4b1cd584,
   	0xe374ef45bf6062ee, 0xa1840eae168a547d, 0x66952c92ecb40fc8, 0x2465cd79455e395b,
   	0x3821458aada7578f, 0x7ad1a461044d611c, 0xbdc0865dfe733aa9, 0xff3067b657990c3a,
   	0x711223cfa3e5bb50, 0x33e2c2240a0f8dc3, 0xf4f3e018f031d676, 0xb60301f359dbe0e5,
   	0xda050215ea6c212f, 0x98f5e3fe438617bc, 0x5fe4c1c2b9b84c09, 0x1d14202910527a9a,
   	0x93366450e42ecdf0, 0xd1c685bb4dc4fb63, 0x16d7a787b7faa0d6, 0x5427466c1e109645,
   	0x4863ce9ff6e9f891, 0x0a932f745f03ce02, 0xcd820d48a53d95b7, 0x8f72eca30cd7a324,
   	0x0150a8daf8ab144e, 0x43a04931514122dd, 0x84b16b0dab7f7968, 0xc6418ae602954ffb,
   	0xbc387aea7a8da4c0, 0xfec89b01d3679253, 0x39d9b93d2959c9e6, 0x7b2958d680b3ff75,
   	0xf50b1caf74cf481f, 0xb7fbfd44dd257e8c, 0x70eadf78271b2539, 0x321a3e938ef113aa,
   	0x2e5eb66066087d7e, 0x6cae578bcfe24bed, 0xabbf75b735dc1058, 0xe94f945c9c3626cb,
   	0x676dd025684a91a1, 0x259d31cec1a0a732, 0xe28c13f23b9efc87, 0xa07cf2199274ca14,
   	0x167ff3eacbaf2af1, 0x548f120162451c62, 0x939e303d987b47d7, 0xd16ed1d631917144,
   	0x5f4c95afc5edc62e, 0x1dbc74446c07f0bd, 0xdaad56789639ab08, 0x985db7933fd39d9b,
   	0x84193f60d72af34f, 0xc6e9de8b7ec0c5dc, 0x01f8fcb784fe9e69, 0x43081d5c2d14a8fa,
   	0xcd2a5925d9681f90, 0x8fdab8ce70822903, 0x48cb9af28abc72b6, 0x0a3b7b1923564425,
   	0x70428b155b4eaf1e, 0x32b26afef2a4998d, 0xf5a348c2089ac238, 0xb753a929a170f4ab,
   	0x3971ed50550c43c1, 0x7b810cbbfce67552, 0xbc902e8706d82ee7, 0xfe60cf6caf321874,
   	0xe224479f47cb76a0, 0xa0d4a674ee214033, 0x67c58448141f1b86, 0x253565a3bdf52d15,
   	0xab1721da49899a7f, 0xe9e7c031e063acec, 0x2ef6e20d1a5df759, 0x6c0603e6b3b7c1ca,
   	0xf6fae5c07d3274cd, 0xb40a042bd4d8425e, 0x731b26172ee619eb, 0x31ebc7fc870c2f78,
   	0xbfc9838573709812, 0xfd39626eda9aae81, 0x3a28405220a4f534, 0x78d8a1b9894ec3a7,
   	0x649c294a61b7ad73, 0x266cc8a1c85d9be0, 0xe17dea9d3263c055, 0xa38d0b769b89f6c6,
   	0x2daf4f0f6ff541ac, 0x6f5faee4c61f773f, 0xa84e8cd83c212c8a, 0xeabe6d3395cb1a19,
   	0x90c79d3fedd3f122, 0xd2377cd44439c7b1, 0x15265ee8be079c04, 0x57d6bf0317edaa97,
   	0xd9f4fb7ae3911dfd, 0x9b041a914a7b2b6e, 0x5c1538adb04570db, 0x1ee5d94619af4648,
   	0x02a151b5f156289c, 0x4051b05e58bc1e0f, 0x87409262a28245ba, 0xc5b073890b687329,
   	0x4b9237f0ff14c443, 0x0962d61b56fef2d0, 0xce73f427acc0a965, 0x8c8315cc052a9ff6,
   	0x3a80143f5cf17f13, 0x7870f5d4f51b4980, 0xbf61d7e80f251235, 0xfd913603a6cf24a6,
   	0x73b3727a52b393cc, 0x31439391fb59a55f, 0xf652b1ad0167feea, 0xb4a25046a88dc879,
   	0xa8e6d8b54074a6ad, 0xea16395ee99e903e, 0x2d071b6213a0cb8b, 0x6ff7fa89ba4afd18,
   	0xe1d5bef04e364a72, 0xa3255f1be7dc7ce1, 0x64347d271de22754, 0x26c49cccb40811c7,
   	0x5cbd6cc0cc10fafc, 0x1e4d8d2b65facc6f, 0xd95caf179fc497da, 0x9bac4efc362ea149,
   	0x158e0a85c2521623, 0x577eeb6e6bb820b0, 0x906fc95291867b05, 0xd29f28b9386c4d96,
   	0xcedba04ad0952342, 0x8c2b41a1797f15d1, 0x4b3a639d83414e64, 0x09ca82762aab78f7,
   	0x87e8c60fded7cf9d, 0xc51827e4773df90e, 0x020905d88d03a2bb, 0x40f9e43324e99428,
   	0x2cffe7d5975e55e2, 0x6e0f063e3eb46371, 0xa91e2402c48a38c4, 0xebeec5e96d600e57,
   	0x65cc8190991cb93d, 0x273c607b30f68fae, 0xe02d4247cac8d41b, 0xa2dda3ac6322e288,
   	0xbe992b5f8bdb8c5c, 0xfc69cab42231bacf, 0x3b78e888d80fe17a, 0x7988096371e5d7e9,
   	0xf7aa4d1a85996083, 0xb55aacf12c735610, 0x724b8ecdd64d0da5, 0x30bb6f267fa73b36,
   	0x4ac29f2a07bfd00d, 0x08327ec1ae55e69e, 0xcf235cfd546bbd2b, 0x8dd3bd16fd818bb8,
   	0x03f1f96f09fd3cd2, 0x41011884a0170a41, 0x86103ab85a2951f4, 0xc4e0db53f3c36767,
   	0xd8a453a01b3a09b3, 0x9a54b24bb2d03f20, 0x5d45907748ee6495, 0x1fb5719ce1045206,
   	0x919735e51578e56c, 0xd367d40ebc92d3ff, 0x1476f63246ac884a, 0x568617d9ef46bed9,
   	0xe085162ab69d5e3c, 0xa275f7c11f7768af, 0x6564d5fde549331a, 0x279434164ca30589,
   	0xa9b6706fb8dfb2e3, 0xeb46918411358470, 0x2c57b3b8eb0bdfc5, 0x6ea7525342e1e956,
   	0x72e3daa0aa188782, 0x30133b4b03f2b111, 0xf7021977f9cceaa4, 0xb5f2f89c5026dc37,
   	0x3bd0bce5a45a6b5d, 0x79205d0e0db05dce, 0xbe317f32f78e067b, 0xfcc19ed95e6430e8,
   	0x86b86ed5267cdbd3, 0xc4488f3e8f96ed40, 0x0359ad0275a8b6f5, 0x41a94ce9dc428066,
   	0xcf8b0890283e370c, 0x8d7be97b81d4019f, 0x4a6acb477bea5a2a, 0x089a2aacd2006cb9,
   	0x14dea25f3af9026d, 0x562e43b4931334fe, 0x913f6188692d6f4b, 0xd3cf8063c0c759d8,
   	0x5dedc41a34bbeeb2, 0x1f1d25f19d51d821, 0xd80c07cd676f8394, 0x9afce626ce85b507,
};
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::hash::fnv32a;

def Fnv32a = distinct uint;

const FNV32A_START @private = 0x811c9dc5;
const FNV32A_MUL @private = 0x01000193;

macro void @update(uint &h, char x) @private => h = (h * FNV32A_MUL) ^ x;

fn void Fnv32a.init(Fnv32a* this)
{
    *this = FNV32A_START;
}

fn void Fnv32a.update(Fnv32a* this, char[] data)
{
	uint h = (uint)*this;
	foreach (char x : data)
    {
        @update(h, x);
    }
    *this = (Fnv32a)h;
}

macro void Fnv32a.update_char(Fnv32a* this, char c)
{
	@update(*this, x);
}

fn uint encode(char[] data)
{
	uint h = FNV32A_START;
	foreach (char x : data)
    {
		@update(h, x);
    }
    return h;
}
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
//
// Implementation was off Steve Reid's SHA-1 C implementation

module std::hash::sha1;
import std::bits;

struct Sha1
{
	uint[5] state;
	uint[2] count;
	char[64] buffer;
}

fn void Sha1.init(Sha1* this)
{
    // SHA1 initialization constants
    *this = {
        .state = {
            0x67452301,
            0xEFCDAB89,
            0x98BADCFE,
            0x10325476,
            0xC3D2E1F0
        }
	};
}

/**
 * @param [&inout] this
 * @param [in] data
 * @require data.len <= uint.max
 **/
fn void Sha1.update(Sha1* this, char[] data)
{
	uint j = this.count[0];
	uint len = data.len;
	if ((this.count[0] += len << 3) < j) this.count[1]++;
	this.count[1] += len >> 29;
	j = (j >> 3) & 63;
	uint i;
	if (j + len > 63)
	{
		i = 64 - j;
		this.buffer[j..] = data[:i];
		sha1_transform(&this.state, &this.buffer);
		for (; i + 63 < len; i += 64)
		{
			sha1_transform(&this.state, &data[i]);
		}
		j = 0;
	}
	this.buffer[j:len - i] = data[i..];
}


fn char[20] Sha1.final(Sha1* this)
{
	char[8] finalcount;
	for (uint i = 0; i < 8; i++)
	{
		finalcount[i] = (char)((this.count[(i >= 4 ? 0 : 1)] >> ((3 - (i & 3)) * 8)) & 0xFF);
	}
	this.update(char[] { 0o200 });
	while ((this.count[0] & 504) != 448)
	{
		this.update(char[] { 0 });
	}

	this.update(&finalcount);
	char[20] digest;
	for (uint i = 0; i < 20; i++)
	{
		digest[i] = (char)((this.state[i >> 2] >> ((3 - (i & 3)) * 8)) & 0xFF);
	}

	// Clear mem
	mem::clear(this, Sha1.sizeof);
	finalcount = {};
	return digest;
}

union Long16 @local
{
	char[64] c;
	uint[16] l;
}

macro @blk(&block, i) @local
{
	return (block.l[i & 15] = (block.l[(i + 13) & 15] ^ block.l[(i + 8) & 15]
		^ block.l[(i + 2) & 15] ^ block.l[i & 15]).rotl(1));
}

macro @blk0(&block, i) @local
{
$if (env::BIG_ENDIAN)
	return block.l[i];
$else
	return block.l[i] = (block.l[i].rotl(24) & 0xFF00FF00)
        | (block.l[i].rotl(8) & 0x00FF00FF);
$endif
}

macro @r0(&block, v, &w, x, y, &z, i) @local
{
	z += ((w & (x ^ y)) ^ y) + @blk0(block, i) + 0x5A827999 + v.rotl(5);
	w = w.rotl(30);
}

macro @r1(&block, v, &w, x, y, &z, i) @local
{
	z += ((w & (x ^ y)) ^ y) + @blk(block, i) + 0x5A827999 + v.rotl(5);
	w = w.rotl(30);
}

macro @r2(&block, v, &w, x, y, &z, i) @local
{
	z += (w ^ x ^ y) + @blk(block, i) + 0x6ED9EBA1 + v.rotl(5);
	w = w.rotl(30);
}

macro @r3(&block, v, &w, x, y, &z, i) @local
{
	z += (((w | x) &y) | (w & x)) + @blk(block, i) + 0x8F1BBCDC + v.rotl(5);
	w = w.rotl(30);
}

macro @r4(&block, v, &w, x, y, &z, i) @local
{
	z += (w ^ x ^ y) + @blk(block, i) + 0xCA62C1D6 + v.rotl(5);
	w = w.rotl(30);
}

/**
 * @param [&inout] state
 * @param [&in] buffer
 **/
fn void sha1_transform(uint* state, char* buffer) @local
{
	Long16 block;
	block.c[..] = buffer[:64];
	uint a = state[0];
	uint b = state[1];
	uint c = state[2];
	uint d = state[3];
	uint e = state[4];
	@r0(block, a, b, c, d, e, 0);
	@r0(block, e, a, b, c, d, 1);
	@r0(block, d, e, a, b, c, 2);
	@r0(block, c, d, e, a, b, 3);
	@r0(block, b, c, d, e, a, 4);
	@r0(block, a, b, c, d, e, 5);
	@r0(block, e, a, b, c, d, 6);
	@r0(block, d, e, a, b, c, 7);
	@r0(block, c, d, e, a, b, 8);
	@r0(block, b, c, d, e, a, 9);
	@r0(block, a, b, c, d, e, 10);
	@r0(block, e, a, b, c, d, 11);
	@r0(block, d, e, a, b, c, 12);
	@r0(block, c, d, e, a, b, 13);
	@r0(block, b, c, d, e, a, 14);
	@r0(block, a, b, c, d, e, 15);
	@r1(block, e, a, b, c, d, 16);
	@r1(block, d, e, a, b, c, 17);
	@r1(block, c, d, e, a, b, 18);
	@r1(block, b, c, d, e, a, 19);
	@r2(block, a, b, c, d, e, 20);
	@r2(block, e, a, b, c, d, 21);
	@r2(block, d, e, a, b, c, 22);
	@r2(block, c, d, e, a, b, 23);
	@r2(block, b, c, d, e, a, 24);
	@r2(block, a, b, c, d, e, 25);
	@r2(block, e, a, b, c, d, 26);
	@r2(block, d, e, a, b, c, 27);
	@r2(block, c, d, e, a, b, 28);
	@r2(block, b, c, d, e, a, 29);
	@r2(block, a, b, c, d, e, 30);
	@r2(block, e, a, b, c, d, 31);
	@r2(block, d, e, a, b, c, 32);
	@r2(block, c, d, e, a, b, 33);
	@r2(block, b, c, d, e, a, 34);
	@r2(block, a, b, c, d, e, 35);
	@r2(block, e, a, b, c, d, 36);
	@r2(block, d, e, a, b, c, 37);
	@r2(block, c, d, e, a, b, 38);
	@r2(block, b, c, d, e, a, 39);
	@r3(block, a, b, c, d, e, 40);
	@r3(block, e, a, b, c, d, 41);
	@r3(block, d, e, a, b, c, 42);
	@r3(block, c, d, e, a, b, 43);
	@r3(block, b, c, d, e, a, 44);
	@r3(block, a, b, c, d, e, 45);
	@r3(block, e, a, b, c, d, 46);
	@r3(block, d, e, a, b, c, 47);
	@r3(block, c, d, e, a, b, 48);
	@r3(block, b, c, d, e, a, 49);
	@r3(block, a, b, c, d, e, 50);
	@r3(block, e, a, b, c, d, 51);
	@r3(block, d, e, a, b, c, 52);
	@r3(block, c, d, e, a, b, 53);
	@r3(block, b, c, d, e, a, 54);
	@r3(block, a, b, c, d, e, 55);
	@r3(block, e, a, b, c, d, 56);
	@r3(block, d, e, a, b, c, 57);
	@r3(block, c, d, e, a, b, 58);
	@r3(block, b, c, d, e, a, 59);
	@r4(block, a, b, c, d, e, 60);
	@r4(block, e, a, b, c, d, 61);
	@r4(block, d, e, a, b, c, 62);
	@r4(block, c, d, e, a, b, 63);
	@r4(block, b, c, d, e, a, 64);
	@r4(block, a, b, c, d, e, 65);
	@r4(block, e, a, b, c, d, 66);
	@r4(block, d, e, a, b, c, 67);
	@r4(block, c, d, e, a, b, 68);
	@r4(block, b, c, d, e, a, 69);
	@r4(block, a, b, c, d, e, 70);
	@r4(block, e, a, b, c, d, 71);
	@r4(block, d, e, a, b, c, 72);
	@r4(block, c, d, e, a, b, 73);
	@r4(block, b, c, d, e, a, 74);
	@r4(block, a, b, c, d, e, 75);
	@r4(block, e, a, b, c, d, 76);
	@r4(block, d, e, a, b, c, 77);
	@r4(block, c, d, e, a, b, 78);
	@r4(block, b, c, d, e, a, 79);
	state[0] += a;
	state[1] += b;
	state[2] += c;
	state[3] += d;
	state[4] += e;
	a = b = c = d = e = 0;
	buffer[:64] = 0;
}
module std::io::os;
import libc;


$switch

$case env::COMPILER_LIBC_AVAILABLE && env::os_is_posix():

macro void! native_chdir(Path p)
{
	if (posix::chdir(p.as_zstr()))
	{
		switch (libc::errno())
		{
			case errno::EACCES: return IoError.NO_PERMISSION?;
			case errno::ENAMETOOLONG: return IoError.NAME_TOO_LONG?;
			case errno::ENOTDIR: return IoError.FILE_NOT_DIR?;
			case errno::ENOENT: return IoError.FILE_NOT_FOUND?;
			case errno::ELOOP: return IoError.SYMLINK_FAILED?;
			default: return IoError.GENERAL_ERROR?;
		}
	}
}

$case env::COMPILER_LIBC_AVAILABLE && env::os_is_win32():

macro void! native_chdir(Path path)
{
	@pool()
	{
		// TODO improve with better error handling.
		if (win32::win32_SetCurrentDirectoryW(path.as_str().to_temp_utf16()!!)) return;
	};
	return IoError.GENERAL_ERROR?;
}

$default:

fn void! native_chdir(Path path)
{
	unreachable("'getcwd' not available");
}

$endswitch
module std::io::os;
import libc;

def FopenFn = fn void*!(String, String);
def FreopenFn = fn void*!(void*, String, String);
def FcloseFn = fn void!(void*);
def FseekFn = fn void!(void*, isz, Seek);
def FtellFn = fn usz!(void*);
def FwriteFn = fn usz!(void*, char[] buffer);
def FreadFn = fn usz!(void*, char[] buffer);

$if (!$defined(native_fopen_fn))
FopenFn native_fopen_fn @weak;
$endif
$if (!$defined(native_fclose_fn))
FcloseFn native_fclose_fn @weak;
$endif
$if (!$defined(native_freopen_fn))
FreopenFn native_freopen_fn @weak;
$endif
$if (!$defined(native_fseek_fn))
FseekFn native_fseek_fn @weak;
$endif
$if (!$defined(native_ftell_fn))
FtellFn native_ftell_fn @weak;
$endif
$if (!$defined(native_fwrite_fn))
FwriteFn native_fwrite_fn @weak;
$endif
$if (!$defined(native_fread_fn))
FreadFn native_fread_fn @weak;
$endif


/**
 * @require mode.len > 0
 * @require filename.len > 0
 **/
fn void*! native_fopen(String filename, String mode) @inline
{
$if (!env::COMPILER_LIBC_AVAILABLE)
		if (native_fopen_fn) return native_fopen_fn(filename, mode);
		unreachable("Tried to call fopen without support.");
$else
	@pool()
	{
	$if (env::os_is_win32())
		void* file = (CFile)_wfopen(filename.to_temp_utf16(), filename.to_temp_utf16())!;
	$else
		void* file = libc::fopen(filename.zstr_tcopy(), mode.zstr_tcopy());
	$endif
		return file ?: file_open_errno()?;
	};
$endif
}

/**
 * @require mode.len > 0
 * @require filename.len > 0
 **/
fn void*! native_freopen(void* file, String filename, String mode) @inline
{
$if (!env::COMPILER_LIBC_AVAILABLE)
		if (native_freopen_fn) return native_freopen_fn(file, filename, mode);
		unreachable("Tried to call freopen without support.");
$else
	@pool()
	{
	$if (env::os_is_win32())
		file = _wfreopen(filename.to_temp_utf16(), mode.to_temp_utf16(), file)!;
	$else
		file = libc::freopen(filename.zstr_tcopy(), mode.zstr_tcopy(), file);
	$endif
		return file ?: file_open_errno()?;
	};
$endif
}

fn void! native_fseek(void* file, isz offset, Seek seek_mode) @inline
{
$if (!env::COMPILER_LIBC_AVAILABLE)
	if (native_fseek_fn) return native_fseek_fn(file, offset, seek_mode);
	unreachable("Tried to call fseek without support.");
$else
	$if (env::os_is_win32())
		bool success = _fseeki64(file, (long)offset, (int)seek_mode) == 0;
	$else
		bool success = libc::fseek(file, (SeekIndex)offset, (CInt)seek_mode) == 0;
	$endif
		if (!success) return file_seek_errno()?;
$endif
}

fn usz! native_ftell(CFile file) @inline
{
$if (!env::COMPILER_LIBC_AVAILABLE)
	if (native_ftell_fn) return native_ftell_fn(file);
	unreachable("Tried to call ftell without support.");
$else
	$if (env::os_is_win32())
		long index = _ftelli64(file);
		return index >= 0 ? index : file_seek_errno()?;
	$else
		SeekIndex index = libc::ftell(file);
		return index >= 0 ? index : file_seek_errno()?;
	$endif
$endif
}

fn usz! native_fwrite(CFile file, char[] buffer) @inline
{
$if (!env::COMPILER_LIBC_AVAILABLE)
	if (native_fwrite_fn) return native_fwrite_fn(file, buffer);
	unreachable("Tried to call fwrite without support.");
$else
    return libc::fwrite(buffer.ptr, 1, buffer.len, file);
$endif
}

fn usz! native_fread(CFile file, char[] buffer) @inline
{
$if (!env::COMPILER_LIBC_AVAILABLE)
	if (native_fread_fn) return native_fread_fn(file, buffer);
	unreachable("Tried to call fread without support.");
$else
    return libc::fread(buffer.ptr, 1, buffer.len, file);
$endif
}

macro anyfault file_open_errno() @local
{
	switch (libc::errno())
	{
	    case errno::EACCES: return IoError.NO_PERMISSION;
	    case errno::EDQUOT: return IoError.OUT_OF_SPACE;
	    case errno::EBADF: return IoError.FILE_NOT_VALID;
	    case errno::EEXIST: return IoError.ALREADY_EXISTS;
	    case errno::EINTR: return IoError.INTERRUPTED;
	    case errno::EFAULT: return IoError.GENERAL_ERROR;
	    case errno::EISDIR: return IoError.FILE_IS_DIR;
	    case errno::ELOOP: return IoError.SYMLINK_FAILED;
	    case errno::EMFILE: return IoError.TOO_MANY_DESCRIPTORS;
	    case errno::ENAMETOOLONG: return IoError.NAME_TOO_LONG;
	    case errno::ENFILE: return IoError.OUT_OF_SPACE;
	    case errno::ENOTDIR: return IoError.FILE_NOT_DIR;
		case errno::ENOENT: return IoError.FILE_NOT_FOUND;
	    case errno::ENOSPC: return IoError.OUT_OF_SPACE;
		case errno::ENXIO: return IoError.FILE_NOT_FOUND;
		case errno::EOVERFLOW: return IoError.OVERFLOW;
		case errno::EROFS: return IoError.READ_ONLY;
		case errno::EOPNOTSUPP: return IoError.UNSUPPORTED_OPERATION;
	    case errno::EIO: return IoError.INCOMPLETE_WRITE;
	    case errno::EWOULDBLOCK: return IoError.WOULD_BLOCK;
	    default: return IoError.UNKNOWN_ERROR;
	}
}

macro anyfault file_seek_errno() @local
{
	switch (libc::errno())
	{
		case errno::ESPIPE: return IoError.FILE_IS_PIPE;
		case errno::EPIPE: return IoError.FILE_IS_PIPE;
		case errno::EOVERFLOW: return IoError.OVERFLOW;
	    case errno::ENXIO: return IoError.FILE_NOT_FOUND;
	    case errno::ENOSPC: return IoError.OUT_OF_SPACE;
        case errno::EIO: return IoError.INCOMPLETE_WRITE;
		case errno::EINVAL: return IoError.INVALID_POSITION;
	    case errno::EINTR: return IoError.INTERRUPTED;
	    case errno::EFBIG: return IoError.OUT_OF_SPACE;
	    case errno::EBADF: return IoError.FILE_NOT_VALID;
	    case errno::EAGAIN: return IoError.WOULD_BLOCK;
	    default: return IoError.UNKNOWN_ERROR;
	}
}

// Win functions
$if (env::os_is_win32())
extern fn void* _wfopen(Char16*, Char16*) @local;
extern fn void* _wfreopen(Char16*, Char16*, CFile) @local;
extern fn int _fseeki64(CFile, long, int) @local;
extern fn long _ftelli64(CFile) @local;
$endif

$if (env::os_is_posix())
extern fn CInt access(ZString path, CInt mode);
$endif
module std::io::file::os;
import libc;

$if (env::os_is_darwin())


struct DarwinTimespec @private
{
	long tv_sec;
	long tv_nsec;
}
struct Darwin64Stat @private
{
	int st_dev;
	ushort st_mode;
	ushort st_nlink;
	ulong st_ino;
	uint st_uid;
	uint st_gid;
	int st_rdev;
	DarwinTimespec st_atimespec; // time of last access
    DarwinTimespec st_mtimespec; // time of last data modification
    DarwinTimespec st_ctimespec; // time of last status change
    DarwinTimespec st_birthtimespec; // time of file creation(birth)
    long st_size;
    long st_blocks;
    int st_blocksize;
    uint st_flags;
    uint st_gen;
    int st_lspare;
    long[2] st_qspare;
}
extern fn int _stat(ZString str, Darwin64Stat* stat) @extern("stat64");

const S_IFMT   = 0o170000; // type of file mask
const S_IFIFO  = 0o010000; // named pipe (fifo)
const S_IFCHR  = 0o020000; // character special
const S_IFDIR  = 0o040000; // directory
const S_IFBLK  = 0o060000; // block special
const S_IFREG  = 0o100000; // regular
const S_IFLNK  = 0o120000; // symbolic link
const S_IFSOCK = 0o140000; // socket

fn usz! native_file_size(String path)
{
	Darwin64Stat stat;
	read_stat(&stat, path)!;
	return stat.st_size;
}

fn bool native_file_or_dir_exists(String path)
{
	Darwin64Stat stat;
	return @ok(read_stat(&stat, path));
}

fn bool native_is_file(String path)
{
	Darwin64Stat stat;
	return @ok(read_stat(&stat, path)) && stat.st_mode & S_IFREG;
}

fn bool native_is_dir(String path)
{
	Darwin64Stat stat;
	return @ok(read_stat(&stat, path)) && stat.st_mode & S_IFDIR;
}

fn void! read_stat(Darwin64Stat* stat, String path) @local
{
	@pool()
	{
		int res = _stat(path.zstr_tcopy(), stat);
		if (res != 0)
		{
			switch (libc::errno())
			{
				case errno::EBADF:
					return IoError.FILE_NOT_VALID?;
				case errno::EFAULT:
					unreachable("Invalid stat");
				case errno::EIO:
					return IoError.GENERAL_ERROR?;
				case errno::EACCES:
					return IoError.NO_PERMISSION?;
				case errno::ELOOP:
					return IoError.NO_PERMISSION?;
				case errno::ENAMETOOLONG:
					return IoError.NAME_TOO_LONG?;
				case errno::ENOENT:
					return IoError.FILE_NOT_FOUND?;
				case errno::ENOTDIR:
					return IoError.FILE_NOT_DIR?;
				case errno::EOVERFLOW:
					return IoError.GENERAL_ERROR?;
				default:
					return IoError.UNKNOWN_ERROR?;
			}
		}
	};
}
$endif
module std::io::file::os;

// native_temp_directory, for non Win32
$if (!env::os_is_win32())

fn Path! native_temp_directory(Allocator* using = mem::heap())
{
	foreach (String env : { "TMPDIR", "TMP", "TEMP", "TEMPDIR" })
	{
		String tmpdir = env::get_var(env) ?? "";
		if (tmpdir) return path::new(tmpdir, using);
	}
	return path::new("/tmp", using);
}

$if (env::COMPILER_LIBC_AVAILABLE)

extern fn void* opendir(ZString);
extern fn void closedir(void*);
extern fn int remove(ZString);

const DT_UNKNOWN =  0;
const DT_FIFO    =  1;
const DT_CHR     =  2;
const DT_DIR     =  4;
const DT_BLK     =  6;
const DT_REG     =  8;
const DT_LNK     = 10;
const DT_SOCK    = 12;
const DT_WHT     = 14;

fn PathList! native_readdir(Path dir, bool no_dirs, bool no_symlinks, String mask, Allocator* using)
{
	PathList list;
	list.init(.using = using);
	void* directory = opendir(dir.as_str() ? dir.as_zstr() : (ZString)".");
	defer if (directory) closedir(directory);
	if (!directory) return (path::is_dir(dir) ? IoError.CANNOT_READ_DIR : IoError.FILE_NOT_DIR)?;
	NativeDirentry* entry;
	while ((entry = readdir(directory)))
	{
		String name = ((ZString)&entry.name).as_str();
		if (!name || name == "." || name == "..") continue;
		if (entry.type == DT_LNK && no_symlinks) continue;
		if (entry.type == DT_DIR && no_dirs) continue;
		Path path = path::new(name.copy(using), using)!!;
		list.append(path);
	}
	return list;
}

/**
 * @require dir.as_str()
 **/
fn void! native_rmtree(Path dir)
{
	void* directory = opendir(dir.as_zstr());
	defer if (directory) closedir(directory);
	if (!directory) return path::is_dir(dir) ? IoError.CANNOT_READ_DIR? : IoError.FILE_NOT_DIR?;
	NativeDirentry* entry;
	while ((entry = readdir(directory)))
	{
		@pool()
		{
			String name = ((ZString)&entry.name).as_str();
            if (!name || name == "." || name == "..") continue;
            Path new_path = dir.tappend(name)!;
            if (entry.type == DT_DIR)
            {
            	native_rmtree(new_path)!;
            	continue;
            }
            if (remove(new_path.as_zstr()))
            {
            	// TODO improve
            	return IoError.GENERAL_ERROR?;
            }
		};
	}
	os::native_rmdir(dir)!;
}

$endif

$endif

$if (!env::os_is_darwin() && !env::os_is_win32())

fn usz! native_file_size(String path)
{
	File f = file::open(path, "r")!;
	defer (void)f.close();
	return f.seek(0, Seek.END)!;
}

$if (env::os_is_posix() && env::COMPILER_LIBC_AVAILABLE)

fn bool native_file_or_dir_exists(String path)
{
	@pool()
	{
		return os::access(path.zstr_tcopy(), 0 /* F_OK */) != -1;
	};
}

fn bool native_is_file(String path)
{
	File! f = file::open(path, "r");
	defer (void)f.close();
	return @ok(f);
}

fn bool native_is_dir(String path)
{
	return native_file_or_dir_exists(path) && !native_is_file(path);
}

$else

fn bool native_file_or_dir_exists(String path)
{
	unreachable("Tried to call file_or_dir_exists without support.");
}

fn bool native_is_dir(String path)
{
	unreachable("Tried to call is_dir without support.");
}

fn bool native_is_file(String path)
{
	unreachable("Tried to call is_file without support.");
}

$endif

$endif

$switch (env::OS_TYPE)
$case IOS:
$case MACOS:
$case TVOS:
$case WATCHOS:

$if (env::ARCH_TYPE == X86_64)
extern fn NativeDirentry* readdir(void*) @extern("readdir$INODE64");
$else
extern fn NativeDirentry* readdir(void*) @extern("readdir");
$endif

struct NativeDirentry
{
	usz ino;
	usz seekoff;
	ushort reclen;
	ushort namelen;
	char type;
	char[1024] name;
}
$case LINUX:
extern fn NativeDirentry* readdir(void*);
struct NativeDirentry
{
	usz ino;
	isz seekoff;
	ushort reclen;
	char type;
	char[*] name;
}
$default:
// Fix this as we go along.
extern fn NativeDirentry* readdir(void*);
struct NativeDirentry
{
	usz ino;
	isz seekoff;
	ushort reclen;
	char type;
	char[*] name;
}
$endswitch
module std::io::file::os;
import std::os::win32;

$if (env::os_is_win32())

const Win32_DWORD FILE_ATTRIBUTE_READONLY = 0x01;
const Win32_DWORD FILE_ATTRIBUTE_HIDDEN = 0x02;
const Win32_DWORD FILE_ATTRIBUTE_SYSTEM = 0x04;
const Win32_DWORD FILE_ATTRIBUTE_DIRECTORY = 0x10;
const Win32_DWORD FILE_ATTRIBUTE_ARCHIVE = 0x20;
const Win32_DWORD FILE_ATTRIBUTE_DEVICE = 0x40;
const Win32_DWORD FILE_ATTRIBUTE_NORMAL = 0x80;
const Win32_DWORD FILE_ATTRIBUTE_TEMPORARY = 0x100;
const Win32_DWORD FILE_ATTRIBUTE_SPARSE_FILE = 0x200;
const Win32_DWORD FILE_ATTRIBUTE_REPARSE_POINT = 0x400;
const Win32_DWORD FILE_ATTRIBUTE_COMPRESSED = 0x800;
const Win32_DWORD FILE_ATTRIBUTE_OFFLINE = 0x1000;
const Win32_DWORD FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x2000;
const Win32_DWORD FILE_ATTRIBUTE_ENCRYPTED = 0x4000;
const Win32_DWORD FILE_ATTRIBUTE_INTEGRITY_STREAM = 0x8000;
const Win32_DWORD FILE_ATTRIBUTE_VIRTUAL = 0x10000;
const Win32_DWORD FILE_ATTRIBUTE_NO_SCRUB_DATA = 0x20000;
const Win32_DWORD FILE_ATTRIBUTE_EA = 0x40000;
const Win32_DWORD FILE_ATTRIBUTE_PINNED = 0x80000;
const Win32_DWORD FILE_ATTRIBUTE_UNPINNED = 0x100000;
const Win32_DWORD FILE_ATTRIBUTE_RECALL_ON_OPEN = 0x40000;
const Win32_DWORD FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS = 0x400000;

fn usz! native_file_size(String path)
{
	@pool()
	{
		Char16[] path16 = path.to_temp_utf16()!;
		Win32_FILE_ATTRIBUTE_DATA data;
		win32::win32_GetFileAttributesExW(path16, Win32_GET_FILEEX_INFO_LEVELS.STANDARD, &data);
		Win32_LARGE_INTEGER size;
		size.lowPart = data.nFileSizeLow;
		size.highPart = data.nFileSizeHigh;
		return (usz)size.quadPart;
	};
}

fn bool native_file_or_dir_exists(String path)
{
	@pool()
	{
		return (bool)win32::win32_PathFileExistsW(path.to_temp_utf16()) ?? false;
	};
}


fn bool native_is_file(String path)
{
	File! f = file::open(path, "r");
	defer (void)f.close();
	return @ok(f);
}

fn bool native_is_dir(String path)
{
	return native_file_or_dir_exists(path) && !native_is_file(path);
}

fn void! native_rmtree(Path path)
{
    Win32_WIN32_FIND_DATAW find_data;

	String s = path.as_str().tconcat("\\*");
	Win32_HANDLE find = win32::win32_FindFirstFileW(s.to_utf16(mem::temp()), &find_data)!;

	if (find == win32::INVALID_HANDLE_VALUE) return IoError.CANNOT_READ_DIR?;

    defer win32::win32_FindClose(find);
	do
	{
		String filename = string::from_zutf16(&find_data.cFileName, mem::temp())!;
		if (filename == "." || filename == "..") continue;
		Path file_path = path.tappend(filename)!;
		if (find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
		{
			native_rmtree(file_path)!;
		}
		else
		{
			win32::win32_DeleteFileW(file_path.as_str().to_utf16(mem::temp()));
		}
	} while (win32::win32_FindNextFileW(find, &find_data) != 0);
    os::native_rmdir(path)!;
}

fn Path! native_temp_directory(Allocator* using = mem::heap())
{
	@stack_mem(256; Allocator* mem)
	{
	    Win32_DWORD len = win32::win32_GetTempPathW(0, null);
		if (!len) return IoError.GENERAL_ERROR?;
		Char16[] buff = malloc(Char16, len + 1, .using = mem);
		if (!win32::win32_GetTempPathW(len, buff)) return IoError.GENERAL_ERROR?;
		return path::new(string::from_utf16(buff[:len], .using = mem), using);
	};
}

/*

	}else if(method == file_size_methods::get_attributes){
		WIN32_FILE_ATTRIBUTE_DATA file_attr_data;
		if(GetFileAttributesEx(path, GetFileExInfoStandard, &file_attr_data)){
			file_size.LowPart = file_attr_data.nFileSizeLow;
			file_size.HighPart = file_attr_data.nFileSizeHigh;
		}
	}
*/
$endif
module std::io::os;
import libc;

$switch

$case env::COMPILER_LIBC_AVAILABLE && env::os_is_win32():

macro String! getcwd(Allocator* using = mem::heap())
{
	const DEFAULT_BUFFER = 256;
	Char16[DEFAULT_BUFFER] buffer;
	Char16 *res = win32::_wgetcwd(&buffer, DEFAULT_BUFFER);
	bool free = false;
	defer if (free) libc::free(res);
	if (!res)
	{
	    if (libc::errno() != errno::ERANGE) return IoError.GENERAL_ERROR?;
		res = win32::_wgetcwd(null, 0);
		free = true;
	}
	Char16[] str16 = res[:win32::wcslen(res)];
	return string::from_utf16(str16, using);
}

$case env::COMPILER_LIBC_AVAILABLE && env::os_is_posix():

macro String! getcwd(Allocator* using = mem::heap())
{
	const usz DEFAULT_BUFFER = 256;
	char[DEFAULT_BUFFER] buffer;
	ZString res = posix::getcwd(&buffer, DEFAULT_BUFFER);
	bool free = false;
	if (!res)
	{
		// Improve error
		if (libc::errno() != errno::ERANGE) return IoError.GENERAL_ERROR?;
		res = posix::getcwd(null, 0);
		free = true;
	}
	defer if (free) libc::free((void*)res);
	return res.copy(using);
}

$default:

fn String! getcwd(Allocator* using = mem::heap())
{
	unreachable("'getcwd' not available");
}

$endswitch
module std::io::os;
import libc;
import std::io::path;
import std::os::win32;
import std::os::posix;

$switch
	$case env::COMPILER_LIBC_AVAILABLE && env::os_is_posix():

macro bool! native_mkdir(Path path, MkdirPermissions permissions)
{
	if (!posix::mkdir(path.as_zstr(), permissions == NORMAL ? 0o777 : 0o700)) return true;
	switch (libc::errno())
	{
		case errno::EACCES:
		case errno::EPERM:
		case errno::EROFS:
		case errno::EFAULT: return IoError.NO_PERMISSION?;
		case errno::ENAMETOOLONG: return IoError.NAME_TOO_LONG?;
		case errno::EDQUOT:
		case errno::ENOSPC: return IoError.OUT_OF_SPACE?;
		case errno::EISDIR:
		case errno::EEXIST: return false;
		case errno::ELOOP: return IoError.SYMLINK_FAILED?;
		case errno::ENOTDIR: return IoError.FILE_NOT_FOUND?;
		default: return IoError.GENERAL_ERROR?;
	}
}

	$case env::COMPILER_LIBC_AVAILABLE && env::os_is_win32():

macro bool! native_mkdir(Path path, MkdirPermissions permissions)
{
	@pool()
    {
        // TODO security attributes
		if (win32::win32_CreateDirectoryW(path.as_str().to_temp_utf16()!!, null)) return true;
		switch (win32::win32_GetLastError())
		{
			case win32::ERROR_ACCESS_DENIED:
				return IoError.NO_PERMISSION?;
			case win32::ERROR_DISK_FULL:
		        return IoError.OUT_OF_SPACE?;
			case win32::ERROR_ALREADY_EXISTS:
				return false;
			case win32::ERROR_PATH_NOT_FOUND:
				return IoError.FILE_NOT_FOUND?;
			default:
				return IoError.GENERAL_ERROR?;
		}
    };
}

	$default:

fn bool! native_mkdir(Path path, MkdirPermissions permissions)
{
	unreachable("'mkdir' not available");
	return false;
}


$endswitch
module std::io::os;
import libc;
import std::io::path;
import std::os::win32;
import std::os::posix;

$switch

$case env::COMPILER_LIBC_AVAILABLE && env::os_is_posix():

macro bool! native_rmdir(Path path)
{
	if (!posix::rmdir(path.as_zstr())) return true;
	switch (libc::errno())
	{
		case errno::EBUSY: return IoError.BUSY?;
		case errno::EACCES:
		case errno::EPERM:
		case errno::EROFS:
		case errno::EFAULT: return IoError.NO_PERMISSION?;
		case errno::ENAMETOOLONG: return IoError.NAME_TOO_LONG?;
		case errno::ENOTDIR:
		case errno::ENOENT: return false;
		case errno::ENOTEMPTY: return IoError.DIR_NOT_EMPTY?;
		case errno::ELOOP: return IoError.SYMLINK_FAILED?;
		default: return IoError.GENERAL_ERROR?;
	}
}

$case env::COMPILER_LIBC_AVAILABLE && env::os_is_win32():

macro bool! native_rmdir(Path path)
{
	@pool()
    {
		if (win32::win32_RemoveDirectoryW(path.as_str().to_temp_utf16()!!)) return true;
		switch (win32::win32_GetLastError())
		{
			case win32::ERROR_ACCESS_DENIED:
				return IoError.NO_PERMISSION?;
			case win32::ERROR_CURRENT_DIRECTORY:
		        return IoError.BUSY?;
			case win32::ERROR_DIR_NOT_EMPTY:
				return IoError.DIR_NOT_EMPTY?;
			case win32::ERROR_DIRECTORY:
			case win32::ERROR_PATH_NOT_FOUND:
				return false;
			default:
				return IoError.GENERAL_ERROR?;
		}
    };
}

$default:

fn bool! native_rmdir(Path path)
{
	unreachable("'rmdir' not available");
}

$endswitch
module std::io;
import std::math;

struct ByteReader
{
	char[] bytes;
	usz index;
}

fn void ByteReader.init(ByteReader* reader, char[] bytes)
{
	*reader = { .bytes = bytes };
}

fn Stream ByteReader.as_stream(ByteReader* reader)
{
	return { .fns = &bytereader_interface, .data = reader };
}

fn usz! ByteReader.read(ByteReader* reader, char[] bytes)
{
	if (reader.index >= reader.bytes.len) return IoError.EOF?;
	usz len = math::min(reader.bytes.len - reader.index, bytes.len);
	if (len == 0) return 0;
	mem::copy(bytes.ptr, &reader.bytes[reader.index], len);
	reader.index += len;
	return len;
}

fn char! ByteReader.read_byte(ByteReader* reader)
{
	if (reader.index >= reader.bytes.len) return IoError.EOF?;
	return reader.bytes[reader.index++];
}

fn void! ByteReader.pushback_byte(ByteReader* reader)
{
	if (!reader.index) return IoError.INVALID_PUSHBACK?;
	reader.index--;
}

fn usz! ByteReader.seek(ByteReader* reader, isz offset, Seek seek)
{
	isz new_index;
	switch (seek)
	{
		case SET: new_index = offset;
		case CURSOR: new_index = reader.index + offset;
		case END: new_index = reader.bytes.len + offset;
	}
	if (new_index < 0) return IoError.INVALID_POSITION?;
	reader.index = new_index;
	return new_index;
}

fn usz! ByteReader.write_stream(ByteReader* reader, Stream* writer)
{
	if (reader.index >= reader.bytes.len) return 0;
	usz written = writer.write(reader.bytes[reader.index..])!;
	reader.index += written;
	assert(reader.index <= reader.bytes.len);
	return written;
}

fn usz ByteReader.available(ByteReader* reader)
{
	return math::max((isz)0, (isz)reader.bytes.len - reader.index);
}

StreamInterface bytereader_interface = {
	.len_fn = fn (s) => ((ByteReader*)s.data).bytes.len,
	.read_fn = fn (s, char[] bytes) => ((ByteReader*)s.data).read(bytes) @inline,
	.read_byte_fn = fn (s) => ((ByteReader*)s.data).read_byte() @inline,
	.pushback_byte_fn = fn (s) => ((ByteReader*)s.data).pushback_byte() @inline,
	.seek_fn = fn (s, offset, seek) => ((ByteReader*)s.data).seek(offset, seek) @inline,
	.write_stream_fn = fn (s, writer) => ((ByteReader*)s.data).write_stream(writer) @inline,
	.available_fn = fn (s) => ((ByteReader*)s.data).available() @inline,
};

module std::io;

struct ByteWriter
{
	char[] bytes;
	usz index;
	Allocator* allocator;
}

/**
 * @param [&inout] writer
 * @param [&in] using
 * @require writer.bytes.len == 0 "Init may not run on on already initialized data"
 * @ensure using != null, index == 0
 **/
fn void ByteWriter.init(ByteWriter* writer, Allocator* using = mem::heap())
{
	*writer = { .bytes = {}, .allocator = using };
}

fn void ByteWriter.init_buffer(ByteWriter* writer, char[] data)
{
	*writer = { .bytes = data, .allocator = null };
}

/**
 * @param [&inout] writer
 * @require writer.bytes.len == 0 "Init may not run on on already initialized data"
 **/
fn void ByteWriter.tinit(ByteWriter* writer)
{
	*writer = { .bytes = {}, .allocator = mem::temp() };
}

fn Stream ByteWriter.as_stream(ByteWriter* writer)
{
	return { .fns = &bytewriter_interface, .data = writer };
}

fn void ByteWriter.destroy(ByteWriter* writer)
{
	if (!writer.allocator) return;
	if (void* ptr = writer.bytes.ptr) free(ptr, .using = writer.allocator);
	*writer = { };
}

fn String ByteWriter.as_str(ByteWriter* writer)
{
	return (String)writer.bytes[:writer.index];
}

fn void! ByteWriter.ensure_capacity(ByteWriter* writer, usz len) @inline
{
	if (writer.bytes.len > len) return;
	if (!writer.allocator) return IoError.OUT_OF_SPACE?;
	if (len < 16) len = 16;
	usz new_capacity = math::next_power_of_2(len);
	char* new_ptr = realloc_checked(writer.bytes.ptr, new_capacity, .using = writer.allocator)!;
	writer.bytes = new_ptr[:new_capacity];
}

fn usz! ByteWriter.write(ByteWriter* writer, char[] bytes)
{
	writer.ensure_capacity(writer.index + bytes.len)!;
	mem::copy(&writer.bytes[writer.index], bytes.ptr, bytes.len);
	writer.index += bytes.len;
	return bytes.len;
}

fn void! ByteWriter.write_byte(ByteWriter* writer, char c)
{
	writer.ensure_capacity(writer.index + 1)!;
	writer.bytes[writer.index++] = c;
}

/**
 * @param [&inout] writer
 * @param [&inout] reader
 **/
fn usz! ByteWriter.read_from(ByteWriter* writer, Stream* reader)
{
	if (reader.supports_available())
	{
		usz total_read = 0;
		while (usz available = reader.available()!)
		{
			writer.ensure_capacity(writer.index + available)!;
			usz len = reader.read(writer.bytes[writer.index..])!;
			total_read += len;
			writer.index += len;
		}
		return total_read;
	}
	usz total_read = 0;
	while (true)
	{
		// See how much we can read.
		usz len_to_read = writer.bytes.len - writer.index;
		// Less than 16 bytes? Double the capacity
		if (len_to_read < 16)
		{
			writer.ensure_capacity(writer.bytes.len * 2)!;
		}
		// Read into the rest of the buffer
		usz read = reader.read(writer.bytes[writer.index..])!;
		writer.index += read;
		// Ok, we reached the end.
		if (read < len_to_read) return total_read;
		// Otherwise go another round
	}
}

StreamInterface bytewriter_interface = {
	.destroy_fn = fn (s) => ((ByteWriter*)s.data).destroy(),
	.len_fn = fn (s) => ((ByteWriter*)s.data).bytes.len,
	.write_fn = fn (s, char[] bytes) => ((ByteWriter*)s.data).write(bytes),
	.write_byte_fn = fn (s, char c) => ((ByteWriter*)s.data).write_byte(c),
	.read_stream_fn = fn (s, reader) => ((ByteWriter*)s.data).read_from(reader),
};
module std::io;

fn Stream DString.as_stream(DString* dstring)
{
	return { .fns = &dstring_interface, .data = dstring };
}

StreamInterface dstring_interface = {
	.destroy_fn = fn (s) => ((DString*)s.data).free(),
	.len_fn = fn (s) => ((DString*)s.data).len(),
	.write_fn = fn (s, char[] bytes) { ((DString*)s.data).append_chars((String)bytes); return bytes.len; },
	.write_byte_fn = fn (s, char c) => ((DString*)s.data).append_char(c),
	.read_stream_fn = fn (s, reader) => ((DString*)s.data).read_from_stream(reader),
};

module std::io;

fn Stream File.as_stream(File* file)
{
	return { .fns = &filestream_interface, .data = file };
}

StreamInterface filestream_interface = {
	.close_fn = fn (s) => ((File*)s.data).close(),
	.seek_fn = fn (s, offset, seek) => ((File*)s.data).seek(offset, seek) @inline,
	.read_fn = fn (s, char[] bytes) => ((File*)s.data).read(bytes) @inline,
	.write_fn = fn (s, char[] bytes) => ((File*)s.data).write(bytes) @inline,
	.write_byte_fn = fn (s, char c) => ((File*)s.data).putc(c) @inline,
	.read_byte_fn = fn (s) => ((File*)s.data).getc() @inline,
	.flush_fn = fn (s) => ((File*)s.data).flush() @inline,
};

// Copyright (c) 2021-2022 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::io;
import libc;

struct File
{
    CFile file;
}

enum Seek
{
    SET,
    CURSOR,
    END
}

fault IoError
{
    FILE_NOT_FOUND,
    FILE_NOT_VALID,
    INVALID_POSITION,
    OVERFLOW,
    FILE_IS_PIPE,
    FILE_EOF,
    INCOMPLETE_WRITE,
    BUSY,
    NO_PERMISSION,
    OUT_OF_SPACE,
    INVALID_PUSHBACK,
    EOF,
    CANNOT_READ_DIR,
    TOO_MANY_DESCRIPTORS,
    FILE_IS_DIR,
    READ_ONLY,
    FILE_NOT_DIR,
    SYMLINK_FAILED,
    ALREADY_EXISTS,
    NOT_SEEKABLE,
    NAME_TOO_LONG,
    WOULD_BLOCK,
    DIR_NOT_EMPTY,
    INTERRUPTED,
    GENERAL_ERROR,
    UNKNOWN_ERROR,
    UNSUPPORTED_OPERATION,
}

fn void putchar(char c) @inline
{
    libc::putchar(c);
}

macro void print(x)
{
	var $Type = $typeof(x);
	$switch ($Type)
	$case String:
		(void)stdout().print(x);
	$case ZString:
		(void)stdout().print(x.as_str());
	$case DString:
		(void)stdout().print(x.str());
	$default:
		$if (@convertible(x, String))
			(void)stdout().print((String)x);
		$else
			(void)stdout().printf("%s", x);
		$endif
	$endswitch
}

macro void printn(x = "")
{
	var $Type = $typeof(x);
	$switch ($Type)
	$case String:
		(void)stdout().printn(x);
	$case ZString:
		(void)stdout().printn(x.as_str());
	$case DString:
		(void)stdout().printn(x.str());
	$default:
		$if (@convertible(x, String))
			(void)stdout().printn((String)x);
		$else
			(void)stdout().printfn("%s", x);
		$endif
	$endswitch
}

fn File stdout()
{
	return { libc::stdout() };
}

fn File stderr()
{
	return { libc::stderr() };
}

fn File stdin()
{
	return { libc::stdin() };
}

/*


error FileError
{
    ulong errno;
}

fn FileError errorFromErrno()
{
    return FileError { };
}




pubic fn void! File.clearerr(File *file) @inline
{
    clearerr(file->file);
}



fn void File.error(File *file) @inline
{
    int err = ferror
}
*/
module std::io::file;
import libc;

fn File! open(String filename, String mode)
{
	return { .file = os::native_fopen(filename, mode) };
}

fn File! open_path(Path path, String mode)
{
	return { .file = os::native_fopen(path.as_str(), mode) };
}

/**
 * @require file.file != null
 **/
fn void! File.reopen(File* file, String filename, String mode)
{
	file.file = os::native_freopen(file.file, filename, mode)!;
}

/**
 * @require file.file != null
 **/
fn usz! File.seek(File file, isz offset, Seek seek_mode = Seek.SET)
{
	os::native_fseek(file.file, offset, seek_mode)!;
	return os::native_ftell(file.file);
}


/*
Implement later
/**
 * @require file.file == null
 **/
fn void! File.memopen(File* file, char[] data, String mode)
{
	@pool()
	{
		file.file = libc::memopen(data.ptr, data.len, mode.zstr_tcopy(), file.file);
		// TODO errors
	};
}
*/


/**
 * @require file && file.file != null
 */
fn void! File.putc(File *file, char c)
{
    if (!libc::fputc(c, file.file)) return IoError.FILE_EOF?;
}

/**
 * @require file != null
 */
fn void! File.close(File *file) @inline
{
    if (file.file && libc::fclose(file.file))
    {
        switch (libc::errno())
        {
            case errno::ECONNRESET:
            case errno::EBADF: return IoError.FILE_NOT_VALID?;
            case errno::EINTR: return IoError.INTERRUPTED?;
            case errno::EDQUOT:
            case errno::EFAULT:
            case errno::EAGAIN:
            case errno::EFBIG:
            case errno::ENETDOWN:
            case errno::ENETUNREACH:
            case errno::ENOSPC:
            case errno::EIO: return IoError.INCOMPLETE_WRITE?;
            default: return IoError.UNKNOWN_ERROR?;
        }
    }
    file.file = null;
}

/**
 * @require file && file.file
 */
fn bool File.eof(File* file) @inline
{
    return libc::feof(file.file) != 0;
}

/**
 * @param [in] buffer
 */
fn usz! File.read(File* file, char[] buffer)
{
	return os::native_fread(file.file, buffer);
}

/**
 * @param [&in] file
 * @param [&out] buffer
 * @require file.file `File must be initialized`
 */
fn usz! File.write(File file, char[] buffer)
{
	return os::native_fwrite(file.file, buffer);
}

/**
 * @param [&in] file
 * @require file.file `File must be initialized`
 */
fn usz! File.printn(File file, String string)
{
	usz len = file.print(string)!;
	if (!libc::putc('\n', file.file)) return IoError.UNKNOWN_ERROR?;
    return len + 1;
}

/**
 * @param [&in] file
 * @require file.file `File must be initialized`
 */
fn usz! File.print(File file, String string)
{
    usz len = string.len;
    if (len != file.write((char[])string)!) return IoError.UNKNOWN_ERROR?;
    return len;
}

/**
 * @param [&in] file
 * @require file.file `File must be initialized`
 */
fn DString File.getline(File* file, Allocator* using = mem::heap())
{
	DString s = dstring::new_with_capacity(120, using);
	while (!file.eof())
	{
		int c = libc::fgetc(file.file);
		if (c == -1) break;
		if (c == '\n') break;
		s.append_char((char)c);
	}
	return s;
}

/**
 * @param [&in] file
 * @require file.file `File must be initialized`
 * @return "a zero terminated String (the pointer may be safely cast into a ZString)"
 */
fn String File.tgetline(File* file)
{
	return file.getline(mem::temp()).zstr().as_str();
}

fn char! File.getc(File* file)
{
	int c = libc::fgetc(file.file);
	if (c == -1) return IoError.FILE_EOF?;
	return (char)c;
}

/**
 * @param [&in] file
 * @require file.file `File must be initialized`
 */
fn void File.flush(File* file)
{
	libc::fflush(file.file);
}

module std::io::file;
import libc;



fn bool is_file(String path)
{
	return os::native_is_file(path);
}

fn usz! get_size(String path)
{
	return os::native_file_size(path);
}
module std::io;

const char[16] XDIGITS_H = "0123456789ABCDEF";
const char[16] XDIGITS_L = "0123456789abcdef";

fn void! Formatter.left_adjust(Formatter* this, usz len) @local
{
	if (!this.flags.left) return;
	for (usz l = len; l < this.width; l++) this.out(' ')!;
}

fn void! Formatter.right_adjust(Formatter* this, usz len) @local
{
	if (this.flags.left) return;
	for (usz l = len; l < this.width; l++) this.out(' ')!;
}


fn uint128! int_from_any(any arg, bool *is_neg) @private
{
	*is_neg = false;
	if (arg.type.kindof == TypeKind.POINTER)
	{
		return (uint128)(uptr)*(void**)arg.ptr;
	}
	if (arg.type.kindof == TypeKind.DISTINCT)
    {
    	return int_from_any(any { arg.ptr, arg.type.inner }, is_neg);
    }
	switch (arg)
	{
		case bool:
			return (uint128)*arg;
		case ichar:
			int val = *arg;
			return (*is_neg = val < 0) ? (~(uint128)val) + 1 : (uint128)val;
		case short:
			int val = *arg;
			return (*is_neg = val < 0) ? (~(uint128)val) + 1 : (uint128)val;
		case int:
			int val = *arg;
			return (*is_neg = val < 0) ? (~(uint128)val) + 1 : (uint128)val;
		case long:
			long val = *arg;
			return (*is_neg = val < 0) ? (~(uint128)val) + 1 : (uint128)val;
		case int128:
            int128 val = *arg;
            return (*is_neg = val < 0) ? (~(uint128)val) + 1 : (uint128)val;
		case char:
			return *arg;
		case ushort:
			return *arg;
		case uint:
			return *arg;
		case ulong:
			return *arg;
		case uint128:
			return *arg;
		case float:
			float f = *arg;
			return (uint128)((*is_neg = f < 0) ? -f : f);
		case double:
			double d = *arg;
			return (uint128)((*is_neg = d < 0) ? -d : d);
		default:
			return PrintFault.INVALID_ARGUMENT_TYPE?;
	}
}

fn FloatType! float_from_any(any arg) @private
{
	$if (env::F128_SUPPORT)
		if (arg.type == float128.typeid) return (FloatType)*((float128*)arg.ptr);
	$endif
	$if (env::F16_SUPPORT)
		if (arg.type == float16.typeid) return *((float16*)arg.ptr);
	$endif
	if (arg.type.kindof == TypeKind.DISTINCT)
	{
		return float_from_any(any { arg.ptr, arg.type.inner });
	}
	switch (arg)
	{
		case bool:
			return (FloatType)*arg;
		case ichar:
			return *arg;
		case short:
			return *arg;
		case int:
			return *arg;
		case long:
			return *arg;
		case int128:
    	    return *arg;
		case char:
			return *arg;
		case ushort:
			return *arg;
		case uint:
			return *arg;
		case ulong:
			return *arg;
		case uint128:
            return *arg;
		case float:
			return (FloatType)*arg;
		case double:
			return (FloatType)*arg;
		default:
			return PrintFault.INVALID_ARGUMENT_TYPE?;
	}
}


/**
 * Read a simple integer value, typically for formatting.
 *
 * @param [inout] len_ptr "the length remaining."
 * @param [in] buf "the buf to read from."
 * @param maxlen "the maximum len that can be read."
 * @return "The result of the atoi."
 **/
fn uint simple_atoi(char* buf, usz maxlen, usz* len_ptr) @inline @private
{
	uint i = 0;
	usz len = *len_ptr;
	while (len < maxlen)
    {
        char c = buf[len];
        if (c < '0' || c > '9') break;
        i = i * 10 + c - '0';
        len++;
    }
    *len_ptr = len;
    return i;
}

fn void! Formatter.out_substr(Formatter *this, String str) @private
{
	usz l = conv::utf8_codepoints(str);
	uint prec = this.prec;
	if (this.flags.precision && l < prec) l = prec;
	this.right_adjust(' ')!;
	usz index = 0;
	usz chars = str.len;
	char* ptr = str.ptr;
	while (index < chars)
	{
		char c = ptr[index];
		// Break if we have precision set and we ran out...
		if (c & 0xC0 != 0x80 && this.flags.precision && !prec--) break;
		this.out(c)!;
        index++;
	}
	return this.left_adjust(l);
}

fn void! Formatter.pad(Formatter* this, char c, isz width, isz len) @inline
{
	for (isz i = len; i < width; i++) this.out(c)!;
}

fn char* fmt_u(uint128 x, char* s)
{
	for (; x > ulong.max; x /= 10) *--s = '0' + (char)(x % 10);
	for (ulong y = (ulong)x; y; y /= 10) *--s = '0' + (char)(y % 10);
	return s;
}

fn void! Formatter.out_chars(Formatter* this, char[] s)
{
	foreach (c : s) this.out(c)!;
}

enum FloatFormatting
{
	FLOAT,
	EXPONENTIAL,
	ADAPTIVE,
	HEX
}

fn void! Formatter.etoa(Formatter* this, double y) => this.floatformat(EXPONENTIAL, y);
fn void! Formatter.ftoa(Formatter* this, double y) => this.floatformat(FLOAT, y);
fn void! Formatter.gtoa(Formatter* this, double y) => this.floatformat(ADAPTIVE, y);
fn void! Formatter.atoa(Formatter* this, double y) => this.floatformat(HEX, y);

fn void! Formatter.floatformat(Formatter* this, FloatFormatting formatting, double y) @private
{
	// This code is heavily based on musl's printf code
	const BUF_SIZE = (math::DOUBLE_MANT_DIG + 28) / 29 + 1
		+ (math::DOUBLE_MAX_EXP + math::DOUBLE_MANT_DIG + 28 + 8) / 9;
	uint[BUF_SIZE] big;
    bool is_neg = false;
    if (math::signbit(y))
    {
        is_neg = true;
        y = -y;
    }
    int pl = is_neg || this.flags.plus ? 1 : 0;
    // Print inf/nan
	if (!math::is_finite(y))
	{
		// Add padding
		if (!this.flags.left) this.pad(' ', this.width, 3 + pl)!;
		String s = this.flags.uppercase ? "INF" : "inf";
		if (y != y) this.flags.uppercase ? "NAN" : "nan";
		if (pl) this.out(is_neg ? '-' : '+')!;
		this.out_chars(s)!;
		if (this.flags.left) this.pad(' ', this.width, 3 + pl)!;
		return;
	}
	// Rescale
	int e2;

	y = math::frexp(y, &e2) * 2;
	if (y) e2--;
	char[12] ebuf0;
	char* ebuf = 12 + (char*)&ebuf0;
	char[9 + math::DOUBLE_MANT_DIG / 4] buf_array;
	char* buf = &buf_array;
	isz p = this.flags.precision ? this.prec : -1;
	if (formatting == HEX)
	{
		double round = 8.0;
		// 0x / 0X
		pl += 2;
		if (p > 0 && p < math::DOUBLE_MANT_DIG / 4 - 1)
		{
			int re = math::DOUBLE_MANT_DIG / 4 - 1 - (int)p;
    		round *= 1 << (math::DOUBLE_MANT_DIG % 4);
    		while (re--) round *= 16;
    		if (is_neg)
    		{
    		    y = -y;
				y -= round;
    			y += round;
    			y = -y;
    		}
    		else
    		{
    		    y += round;
    			y -= round;
    		}
		}
		// Reverse print
		char* estr = fmt_u(e2 < 0 ? (int128)-e2 : (int128)e2, ebuf);
		if (estr == ebuf) *--estr = '0';
		*--estr = (e2 < 0 ? '-' : '+');
		*--estr = this.flags.uppercase ? 'P' : 'p';
		char* s = buf;
		char* xdigits = this.flags.uppercase ? &XDIGITS_H : &XDIGITS_L;
		do
		{
			int x = (int)y;
			*s++ = xdigits[x];
			y = 16 * (y - x);
			if (s - buf == 1 && (y || p > 0 || this.flags.hash)) *s++ = '.';
		} while (y);
		isz outlen = s - buf;
		isz explen = ebuf - estr;
		if (p > int.max - 2 - explen - pl) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
		usz l = p && outlen - 2 < p
				? p + 2 + explen
				: outlen + explen;
		if (!this.flags.left && !this.flags.zeropad) this.pad(' ', this.width, pl + l)!;
		if (is_neg || this.flags.plus) this.out(is_neg ? '-' : '+')!;
		this.out_chars(this.flags.uppercase ? "0X" : "0x")!;
		if (this.flags.zeropad) this.pad('0', this.width, pl + l)!;
		this.out_chars(buf[:outlen])!;
		this.pad('0', l - outlen - explen, 0)!;
		this.out_chars(estr[:explen])!;
		if (this.flags.left) this.pad(' ', this.width, pl + l)!;
		return;
	}
	if (p < 0) p = 6;
	if (y)
	{
		y *= 0x1p28;
		e2 -= 28;
	}

	uint* a, z, r;
	if (e2 < 0)
	{
		a = r = z = &big;
	}
	else
	{
		a = r = z = (uint*)&big + big.len - math::DOUBLE_MANT_DIG - 1;
	}

	do
	{
		uint v = z++[0] = (uint)y;
		y = 1000000000 * (y - v);
	} while (y);

	while (e2 > 0)
	{
		uint carry = 0;
		int sh = math::min(29, e2);
		for (uint* d = z - 1; d >= a; d--)
		{
			ulong x = (ulong)*d << sh + carry;
			*d = (uint)(x % 1000000000);
			carry = (uint)(x / 1000000000);
		}
		if (carry) *--a = carry;
		while (z > a && !z[-1]) z--;
		e2 -= sh;
	}

	while (e2 < 0)
	{
		uint carry = 0;
		uint* b;
		int sh = math::min(9, -e2);
		int need = (int)(1 + (p + math::DOUBLE_MANT_DIG / 3u + 8) / 9);
		for (uint* d = a; d < z; d++)
		{
			// CHECK THIS
			uint rm = *d & ((1 << sh) - 1);
			*d = (*d >> sh) + carry;
			carry = (1000000000 >> sh) * rm;
		}
		if (!a[0]) a++;
		if (carry) z++[0] = carry;
		// Avoid (slow!) computation past requested precision
		b = formatting == FLOAT ? r : a;
		if (z - b > need) z = b + need;
		e2 += sh;
	}

	int e;
	if (a < z)
	{
		for (int i = 10, e = (int)(9 * (r - a)); *a >= i; i *= 10, e++);
	}

	// Perform rounding: j is precision after the radix (possibly neg)
	int j = (int)(p - (isz)(formatting == FLOAT ? 0 : e - (int)(formatting == ADAPTIVE && p)));
	if (j < 9 * (z - r - 1))
	{
		uint x;
		// We avoid C's broken division of negative numbers
		uint* d = r + 1 + ((j + 9 * math::DOUBLE_MAX_EXP) / 9 - math::DOUBLE_MAX_EXP);
		j += 9 * math::DOUBLE_MAX_EXP;
		j %= 9;
		int i;
		for (i = 10, j++; j < 9; i *= 10, j++);
		x = *d % i;
		// Are there any significant digits past j?
		if (x || (d + 1) != z)
		{
			double round = 2 / math::DOUBLE_EPSILON;
			double small;
			if (((*d / i) & 1) || (i == 1000000000 && d > a && (d[-1] & 1)))
			{
				round += 2;
			}
			switch
			{
				case x < i / 2:
					small = 0x0.8p0;
				case x == i / 2 && d + 1 == z:
					small = 0x1.0p0;
				default:
					small = 0x1.8p0;
			}
			if (pl && is_neg)
			{
				round *= -1;
				small *= -1;
			}
			*d -= x;
			// Decide whether to round by probing round+small
			if (round + small != round)
			{
				*d = *d + i;
				while (*d > 999999999)
				{
					*d-- = 0;
					if (d < a) *--a = 0;
					(*d)++;
				}
				for (i = 10, e = (int)(9 * (r - a)); *a >= i; i *= 10, e++);
			}
		}
		if (z > d + 1) z = d + 1;
	}
	for (; z>a && !z[-1]; z--);

	if (formatting == ADAPTIVE)
	{
		if (!p) p++;
		if (p > e && e >= -4)
		{
			formatting = FLOAT;
			p -= (isz)e + 1;
		}
		else
		{
			formatting = EXPONENTIAL;
			p--;
		}
		if (!this.flags.hash)
		{
			// Count trailing zeros in last place
			if (z > a && z[-1])
			{
				for (int i = 10, j = 0; z[-1] % i == 0; i *= 10, j++);
			}
			else
			{
				j = 9;
			}
			if (formatting == FLOAT)
			{
				p = math::min(p, math::max((isz)0, 9 * (z - r - 1) - j));
			}
			else
			{
				p = math::min(p, math::max((isz)0, 9 * (z - r - 1) + e - j));

			}
		}
	}
	if (p > int.max - 1 - (isz)(p || this.flags.hash)) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
	int l = (int)(1 + p + (isz)(p || this.flags.hash));
	char* estr @noinit;
	if (formatting == FLOAT)
	{
		if (e > int.max - l) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
		if (e > 0) l += e;
	}
	else
	{
		estr = fmt_u((uint128)(e < 0 ? -e : e), ebuf);
		while (ebuf - estr < 2) (--estr)[0] = '0';
		*--estr = (e < 0 ? '-' : '+');
		*--estr = this.flags.uppercase ? 'E' : 'e';
		if (ebuf - estr > (isz)int.max - l) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
		l += (int)(ebuf - estr);
	}
	if (l > int.max - pl) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
	if (!this.flags.left && !this.flags.zeropad) this.pad(' ', this.width, pl + l)!;
	if (is_neg || this.flags.plus) this.out(is_neg ? '-' : '+')!;
	if (this.flags.zeropad) this.pad('0', this.width, pl + l)!;
	if (formatting == FLOAT)
	{
		if (a > r) a = r;
		uint* d = a;
		for (; d <= r; d++)
		{
			char* s = fmt_u(*d, buf + 9);
			switch
			{
				case d != a:
					while (s > buf) (--s)[0] = '0';
				case s == buf + 9:
					*--s = '0';
			}
			this.out_chars(s[:buf + 9 - s])!;
		}
		if (p || this.flags.hash) this.out('.')!;
		for (; d < z && p > 0; d++, p -= 9)
		{
			char* s = fmt_u(*d, buf + 9);
			while (s > buf) *--s = '0';
			this.out_chars(s[:math::min((isz)9, p)])!;
		}
		this.pad('0', p + 9, 9)!;
	}
	else
	{
		if (z <= a) z = a + 1;
    	for (uint* d = a; d < z && p >= 0; d++)
    	{
			char* s = fmt_u(*d, buf + 9);
			if (s == buf + 9) (--s)[0] = '0';
    		if (d != a)
    		{
    		    while (s > buf) (--s)[0] = '0';
    		}
    		else
    		{
    		    this.out(s++[0])!;
    		    if (p > 0 || this.flags.hash) this.out('.')!;
    		}
    		this.out_chars(s[:math::min(buf + 9 - s, p)])!;
    		p -= buf + 9 - s;
    	}
    	this.pad('0', p + 18, 18)!;
    	this.out_chars(estr[:ebuf - estr])!;
	}

	if (this.flags.left) this.pad(' ', this.width, pl + l)!;

	return;
}

fn void! Formatter.ntoa(Formatter* this, uint128 value, bool negative, uint base) @private
{
	char[PRINTF_NTOA_BUFFER_SIZE] buf @noinit;
	usz len = 0;

	// no hash for 0 values
	if (!value) this.flags.hash = false;

	// write if precision != 0 or value is != 0
	if (!this.flags.precision || value)
	{
		char past_10 = (this.flags.uppercase ? 'A' : 'a') - 10;
		do
		{
			if (len >= PRINTF_NTOA_BUFFER_SIZE) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
			char digit = (char)(value % base);
			buf[len++] = digit + (digit < 10 ? '0' : past_10);
			value /= base;
		}
		while (value);
	}
	return this.ntoa_format((String)buf[:PRINTF_NTOA_BUFFER_SIZE], len, negative, base);
}

fn void! Formatter.ntoa_format(Formatter* this, String buf, usz len, bool negative, uint base) @private
{
	// pad leading zeros
	if (!this.flags.left)
	{
		if (this.width && this.flags.zeropad && (negative || this.flags.plus || this.flags.space)) this.width--;
		while (len < this.prec)
		{
			if (len >= buf.len) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
			buf[len++] = '0';
		}
		while (this.flags.zeropad && len < this.width)
		{
			if (len >= buf.len) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
			buf[len++] = '0';
		}
	}

	// handle hash
	if (this.flags.hash && base != 10)
	{
		if (!this.flags.precision && len && len == this.prec && len == this.width)
		{
			len--;
			if (len) len--;
		}
		if (base != 10)
		{
			if (len + 1 >= buf.len) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
			switch (base)
			{
				case 16:
					buf[len++] = this.flags.uppercase ? 'X' : 'x';
				case 8:
					buf[len++] = this.flags.uppercase ? 'O' : 'o';
				case 2:
					buf[len++] = this.flags.uppercase ? 'B' : 'b';
				default:
					unreachable();
			}
			buf[len++] = '0';
		}
	}

	switch (true)
	{
		case negative:
			if (len >= buf.len) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
			buf[len++] = '-';
		case this.flags.plus:
			if (len >= buf.len) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
			buf[len++] = '+';
		case this.flags.space:
			if (len >= buf.len) return PrintFault.INTERNAL_BUFFER_EXCEEDED?;
			buf[len++] = ' ';
	}
	if (!len) return;
	return this.out_reverse(buf[:len]);
}


fn void! Formatter.ntoa_any(Formatter* this, any arg, uint base) @private
{
	bool is_neg;
	uint128 val = int_from_any(arg, &is_neg)!!;
	return this.ntoa(val, is_neg, base) @inline;
}

fn void! Formatter.out_char(Formatter* this, any arg) @private
{
	uint l = 1;
	// pre padding
	this.right_adjust(l)!;
    // char output
    Char32 c = types::any_to_int(arg, uint) ?? 0xFFFD;
	switch (true)
	{
		case c < 0x7f:
			this.out((char)c)!;
		case c < 0x7ff:
			this.out((char)(0xC0 | c >> 6))!;
			this.out((char)(0x80 | (c & 0x3F)))!;
        case c < 0xffff:
			this.out((char)(0xE0 | c >> 12))!;
			this.out((char)(0x80 | (c >> 6 & 0x3F)))!;
			this.out((char)(0x80 | (c & 0x3F)))!;
        default:
			this.out((char)(0xF0 | c >> 18))!;
			this.out((char)(0x80 | (c >> 12 & 0x3F)))!;
			this.out((char)(0x80 | (c >> 6 & 0x3F)))!;
			this.out((char)(0x80 | (c & 0x3F)))!;
	}
	return this.left_adjust(l);
}


fn void! Formatter.out_reverse(Formatter* this, char[] buf) @private
{
	usz buffer_start_idx = this.idx;
	usz len = buf.len;
    // pad spaces up to given width
    if (!this.flags.left && !this.flags.zeropad)
    {
        for (usz i = len; i < this.width; i++)
        {
            this.out(' ')!;
        }
    }
    // reverse string
    while (len) this.out(buf[--len])!;

	// append pad spaces up to given width
	return this.left_adjust(this.idx - buffer_start_idx);
}

fn void! printf_advance_format(usz format_len, usz *index_ptr) @inline @private
{
	usz val = ++(*index_ptr);
	if (val >= format_len) return FormattingFault.UNTERMINATED_FORMAT?;
}

fn any! next_any(any* args_ptr, usz args_len, usz* arg_index_ptr) @inline @private
{
	if (*arg_index_ptr >= args_len) return FormattingFault.MISSING_ARG?;
	return args_ptr[(*arg_index_ptr)++];
}

fn int! printf_parse_format_field(
	any* args_ptr, usz args_len, usz* args_index_ptr,
	char* format_ptr, usz format_len, usz* index_ptr) @inline @private
{
	char c = format_ptr[*index_ptr];
	if (c >= '0' && c <= '9') return simple_atoi(format_ptr, format_len, index_ptr);
	if (c != '*') return 0;
	printf_advance_format(format_len, index_ptr)!;
	any val = next_any(args_ptr, args_len, args_index_ptr)!;
    if (!val.type.kindof.is_int()) return FormattingFault.INVALID_WIDTH_ARG?;
    uint! intval = types::any_to_int(val, int);
	return intval ?? FormattingFault.INVALID_WIDTH_ARG?;
}
module std::io;
import std::collections::map;
import libc;

const int PRINTF_NTOA_BUFFER_SIZE = 256;

fault PrintFault
{
	BUFFER_EXCEEDED,
	INTERNAL_BUFFER_EXCEEDED,
	INVALID_FORMAT_STRING,
	MISSING_ARG,
	INVALID_ARGUMENT_TYPE,
}

fault FormattingFault
{
	UNTERMINATED_FORMAT,
	MISSING_ARG,
	INVALID_WIDTH_ARG,
	INVALID_FORMAT_TYPE,
}

def OutputFn = fn void!(char c, void* buffer);
def ToStringFunction = fn String(void* value, Allocator *using);
def ToFormatFunction = fn void!(void* value, Formatter* formatter);
def FloatType = double;

fn usz! printf(String format, args...) @maydiscard
{
	Formatter formatter;
	formatter.init(&out_putchar_fn);
    return formatter.vprintf(format, args);
}

fn usz! printfn(String format, args...) @maydiscard
{
	Formatter formatter;
	formatter.init(&out_putchar_fn);
    usz len = formatter.vprintf(format, args)!;
	putchar('\n');
	return len + 1;
}

fn char[]! bprintf(char[] buffer, String format, args...) @maydiscard
{
	Formatter formatter;
	BufferData data = { .buffer = buffer };
    formatter.init(&out_buffer_fn, &data);
    usz size = formatter.vprintf(format, args)!;
    return buffer[:data.written];
}

fn usz! File.printf(File file, String format, args...) @maydiscard
{
	Formatter formatter;
    formatter.init(&out_fputchar_fn, &file);
    return formatter.vprintf(format, args)!;
}

fn usz! File.printfn(File file, String format, args...) @maydiscard
{
	Formatter formatter;
    formatter.init(&out_fputchar_fn, &file);
    usz len = formatter.vprintf(format, args)!;
	file.putc('\n')!;
	file.flush();
	return len + 1;
}

fn usz! Formatter.printf(Formatter* this, String format, args...)
{
	return this.vprintf(format, args) @inline;
}

struct Formatter
{
	void *data;
	OutputFn out_fn;
	struct
	{
		PrintFlags flags;
    	uint width;
    	uint prec;
    	usz idx;
	}
}

bitstruct PrintFlags : uint
{
	bool zeropad : 0;
	bool left : 1;
	bool plus : 2;
	bool space : 3;
	bool hash : 4;
	bool uppercase : 5;
	bool precision : 6;
}

fn void Formatter.init(Formatter* this, OutputFn out_fn, void* data = null)
{
	*this = { .data = data, .out_fn = out_fn};
}

/**
 * @require $checks($Type a, a.to_string()) || $checks($Type a, a.to_format(&&Formatter{}))  "Expected a type with 'to_string' or 'to_format' defined"
 * @require !$checks($Type a, a.to_string()) || $checks($Type a, a.to_string(&&Allocator{})) "Expected 'to_string' to take an allocator as argument."
 * @require !$checks($Type a, a.to_format(&&Formatter{})) || $checks($Type a, Formatter b, a.to_format(&b)) "Expected 'to_format' to take a Formatter as argument."
 */
macro void formatter_register_type($Type)
{
	$if ($checks($Type a, a.to_format(&&Formatter {})))
		if (!toformat_functions.table.len)
		{
			toformat_functions.init(64);
		}
		toformat_functions.set($Type.typeid, (ToFormatFunction)&$Type.to_format);
	$else
		if (!tostring_functions.table.len)
		{
			tostring_functions.init(64);
		}
		tostring_functions.set($Type.typeid, (ToStringFunction)&$Type.to_string);
	$endif
}


static initialize @priority(101)
{
	if (!toformat_functions.table.len)
	{
		toformat_functions.init(64);
	}
	if (!tostring_functions.table.len)
	{
		tostring_functions.init(64);
	}
}

fn void! Formatter.out(Formatter* this, char c) @private
{
	this.out_fn(c, this.data)!;
}

macro bool! Formatter.print_with_function(Formatter* this, any arg)
{
	if (try to_format = toformat_functions.get(arg.type))
	{
		PrintFlags old = this.flags;
		uint old_width = this.width;
		uint old_prec = this.prec;
		defer
		{
			this.flags = old;
			this.width = old_width;
			this.prec = old_prec;
		}
		to_format(arg.ptr, this)!;
		return true;
    }
    if (try to_string = tostring_functions.get(arg.type))
    {
		PrintFlags old = this.flags;
		uint old_width = this.width;
		uint old_prec = this.prec;
		defer
		{
			this.flags = old;
			this.width = old_width;
			this.prec = old_prec;
		}
		@pool()
		{
			this.out_substr(to_string(arg.ptr, mem::temp()))!;
			return true;
		};
    }
    return false;
}

fn void! Formatter.out_str(Formatter* this, any arg) @private
{
	switch (arg.type.kindof)
	{
		case TYPEID:
			return this.out_substr("typeid");
		case VOID:
        	return this.out_substr("void");
		case ANYFAULT:
		case FAULT:
        	return this.out_substr((*(anyfault*)arg.ptr).nameof);
		case ANY:
			return this.out_str(*(any*)arg);
		case ENUM:
			if (this.print_with_function(arg)!) return;
        	return this.out_substr(arg.type.names[types::any_to_int(arg, usz)!!]);
		case STRUCT:
			if (this.print_with_function(arg)!) return;
			return this.out_substr("<struct>");
		case UNION:
			if (this.print_with_function(arg)!) return;
			return this.out_substr("<union>");
		case BITSTRUCT:
			if (this.print_with_function(arg)!) return;
			return this.out_substr("<bitstruct>");
		case FUNC:
			if (this.print_with_function(arg)!) return;
			return this.out_substr("<function>");
		case OPTIONAL:
			unreachable();
		case DISTINCT:
			if (this.print_with_function(arg)!) return;
			if (arg.type == DString.typeid)
			{
				return this.out_substr(((DString*)arg).str());
			}
        	return this.out_str(any { arg.ptr, arg.type.inner });
		case POINTER:
			if (this.print_with_function(arg)!) return;
			return this.ntoa_any(arg, 16);
		case SIGNED_INT:
		case UNSIGNED_INT:
			return this.ntoa_any(arg, 10);
		case FLOAT:
			return this.ftoa(float_from_any(arg)!!);
		case ARRAY:
			if (this.print_with_function(arg)!) return;
			// this is SomeType[*] so grab the "SomeType"
			typeid inner = arg.type.inner;
			usz size = inner.sizeof;
			usz len = arg.type.len;
			// Pretend this is a String
			void* ptr = (void*)arg.ptr;
			this.out('[')!;
			for (usz i = 0; i < len; i++)
			{
				if (i != 0) this.out_substr(", ")!;
				this.out_str(any { ptr, inner })!;
				ptr += size;
			}
			return this.out(']');
		case VECTOR:
			if (this.print_with_function(arg)!) return;
			// this is SomeType[*] so grab the "SomeType"
			typeid inner = arg.type.inner;
			usz size = inner.sizeof;
			usz len = arg.type.len;
			// Pretend this is a String
			void* ptr = (void*)arg.ptr;
			this.out_substr("[<")!;
			for (usz i = 0; i < len; i++)
			{
				if (i != 0) this.out_substr(", ")!;
				this.out_str(any { ptr, inner })!;
				ptr += size;
			}
			return this.out_substr(">]");
		case SUBARRAY:
			if (this.print_with_function(arg)!) return;
			// this is SomeType[] so grab the "SomeType"
			typeid inner = arg.type.inner;
			if (inner == char.typeid)
			{
				return this.out_substr(*(String*)arg);
			}
			usz size = inner.sizeof;
            // Pretend this is a String
			String* temp = (void*)arg.ptr;
			void* ptr = (void*)temp.ptr;
			usz len = temp.len;
			this.out('[')!;
			for (usz i = 0; i < len; i++)
			{
				if (i != 0) this.out_substr(", ")!;
				this.out_str(any { ptr, inner })!;
				ptr += size;
			}
			this.out(']')!;
		case BOOL:
			if (*(bool*)arg.ptr)
			{
				return this.out_substr("true");
			}
			else
			{
				return this.out_substr("false");
			}
		default:
			switch (arg)
			{
				case Object:
					arg.to_format(this)!;
					return;
			}
			if (this.print_with_function(arg)!) return;
			return this.out_substr("Invalid type");
	}
}



fn void! out_buffer_fn(char c, void *data) @private
{
	BufferData *buffer_data = data;
	if (buffer_data.written >= buffer_data.buffer.len) return PrintFault.BUFFER_EXCEEDED?;
	buffer_data.buffer[buffer_data.written++] = c;
}

fn void! out_null_fn(char c @unused, void* data @unused) @private
{
}

fn void! out_putchar_fn(char c, void* data @unused) @private
{
	libc::putchar(c);
}

fn void! out_fputchar_fn(char c, void* data) @private
{
	File* f = data;
	f.putc(c)!;
}

struct BufferData @private
{
	char[] buffer;
	usz written;
}


fn usz! Formatter.vprintf(Formatter* this, String format, any[] anys)
{
	if (!this.out_fn)
	{
		// use null output function
		this.out_fn = &out_null_fn;
	}
	usz format_len = format.len;
	usz variant_index = 0;
	for (usz i = 0; i < format_len; i++)
	{
		// format specifier?  %[flags][width][.precision][length]
		char c = format[i];
		if (c != '%')
		{
			// no
			this.out(c)!;
			continue;
		}
		i++;
		if (i >= format_len) return PrintFault.INVALID_FORMAT_STRING?;
		c = format[i];
		if (c == '%')
		{
			this.out(c)!;
			continue;
		}
		// evaluate flags
		this.flags = {};
		while FLAG_EVAL: (true)
		{
			switch (c)
			{
				case '0': this.flags.zeropad = true;
				case '-': this.flags.left = true;
				case '+': this.flags.plus = true;
				case ' ': this.flags.space = true;
				case '#': this.flags.hash = true;
				default: break FLAG_EVAL;
			}
			if (++i >= format_len) return PrintFault.INVALID_FORMAT_STRING?;
			c = format[i];
		}
		// evaluate width field
		int w = printf_parse_format_field(anys.ptr, anys.len, &variant_index, format.ptr, format.len, &i)!;
		c = format[i];
		if (w < 0)
		{
			this.flags.left = true;
			w = -w;
		}
		this.width = w;
		// evaluate precision field
		this.prec = 0;
		if (c == '.')
		{
			this.flags.precision = true;
			if (++i >= format_len) return PrintFault.INVALID_FORMAT_STRING?;
			int prec = printf_parse_format_field(anys.ptr, anys.len, &variant_index, format.ptr, format.len, &i)!;
			this.prec = prec < 0 ? 0 : prec;
			c = format[i];
		}

		// evaluate specifier
		uint base = 0;
		if (variant_index >= anys.len) return PrintFault.MISSING_ARG?;
		any current = anys[variant_index++];
		switch (c)
		{
			case 'd':
				base = 10;
				this.flags.hash = false;
			case 'X' :
				this.flags.uppercase = true;
				nextcase;
			case 'x' :
				base = 16;
			case 'O':
				this.flags.uppercase = true;
				nextcase;
			case 'o' :
				base = 8;
			case 'B':
				this.flags.uppercase = true;
				nextcase;
			case 'b' :
				base = 2;
			case 'A':
				this.flags.uppercase = true;
				nextcase;
			case 'a':
				this.atoa(float_from_any(current)!!)!;
				continue;
		    case 'F' :
		        this.flags.uppercase = true;
		        nextcase;
		    case 'f':
		        this.ftoa(float_from_any(current)!!)!;
				continue;
			case 'E':
		        this.flags.uppercase = true;
		        nextcase;
            case 'e':
                this.etoa(float_from_any(current)!!)!;
				continue;
			case 'G':
				this.flags.uppercase = true;
				nextcase;
			case 'g':
				this.gtoa(float_from_any(current)!!)!;
				continue;
			case 'c':
				this.out_char(current)!;
				continue;
			case 's':
				this.out_str(current)!;
				continue;
			case 'p':
				this.flags.zeropad = true;
				this.flags.hash = true;
				base = 16;
			default:
				return PrintFault.INVALID_FORMAT_STRING?;
		}
		if (base != 10)
		{
			this.flags.plus = false;
			this.flags.space = false;
		}
		// ignore '0' flag when precision is given
		if (this.flags.precision) this.flags.zeropad = false;

		bool is_neg;
		uint128 v = int_from_any(current, &is_neg)!!;

		this.ntoa(v, is_neg, base)!;
	}
	// termination
	//	out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);

	// return written chars without terminating \0
	return this.idx;
}

def StringFunctionMap @private = HashMap<typeid, ToStringFunction>;
def FormatterFunctionMap @private = HashMap<typeid, ToFormatFunction>;

FormatterFunctionMap toformat_functions @private;
StringFunctionMap tostring_functions @private;
module std::io;

def CloseStreamFn = fn void!(Stream*);
def FlushStreamFn = fn void!(Stream*);
def SeekStreamFn = fn usz!(Stream*, isz offset, Seek seek);
def LenStreamFn = fn usz(Stream*);
def AvailableStreamFn = fn usz(Stream*);
def ReadStreamFn = fn usz!(Stream*, char[] bytes);
def ReadFromStreamFn = fn usz!(Stream*, Stream*);
def ReadByteStreamFn = fn char!(Stream*);
def PushbackByteStreamFn = fn void!(Stream*);
def WriteStreamFn = fn usz!(Stream*, char[] bytes);
def WriteToStreamFn = fn usz!(Stream*, Stream* out);
def WriteByteStreamFn = fn void!(Stream*, char c);
def DestroyStreamFn = fn void!(Stream*);

struct StreamInterface
{
	CloseStreamFn close_fn;
	FlushStreamFn flush_fn;
	SeekStreamFn seek_fn;
	LenStreamFn len_fn;
	AvailableStreamFn available_fn;
	ReadStreamFn read_fn;
	ReadFromStreamFn read_stream_fn;
	ReadByteStreamFn read_byte_fn;
	PushbackByteStreamFn pushback_byte_fn;
	WriteStreamFn write_fn;
	WriteToStreamFn write_stream_fn;
	WriteByteStreamFn write_byte_fn;
	DestroyStreamFn destroy_fn;
}

struct Stream
{
	StreamInterface *fns;
	void* data;
}

fn bool Stream.supports_seek(Stream* s) @inline => (bool)s.fns.seek_fn;
fn bool Stream.supports_available(Stream* s) @inline => s.fns.available_fn || s.fns.seek_fn;
fn bool Stream.supports_len(Stream* s) @inline => s.fns.len_fn || s.fns.seek_fn;
fn bool Stream.supports_read(Stream* s) @inline => s.fns.read_fn || s.fns.read_byte_fn;
fn bool Stream.supports_read_from(Stream* s) @inline => (bool)s.fns.read_stream_fn;
fn bool Stream.supports_write_to(Stream* s) @inline => (bool)s.fns.write_stream_fn;
fn bool Stream.supports_pushback_byte(Stream* s) @inline => s.fns.pushback_byte_fn || s.fns.seek_fn;
fn bool Stream.supports_write(Stream* s) @inline => s.fns.write_fn || s.fns.write_byte_fn;

fn void! Stream.destroy(Stream* s) @inline @maydiscard
{
	if (s.fns.destroy_fn) return s.fns.destroy_fn(s);
	return s.close();
}

fn void! Stream.close(Stream* s) @inline @maydiscard
{
	if (CloseStreamFn func = s.fns.close_fn) return func(s);
}

fn usz! Stream.seek(Stream* s, isz offset, Seek seek) @inline
{
	if (SeekStreamFn func = s.fns.seek_fn) return func(s, offset, seek);
	return IoError.NOT_SEEKABLE?;
}

fn usz! Stream.available(Stream* s) @inline
{
	if (AvailableStreamFn func = s.fns.available_fn) return func(s);
	if (SeekStreamFn func = s.fns.seek_fn)
	{
		usz curr = func(s, 0, Seek.CURSOR)!;
		usz len = func(s, 0, Seek.END)!;
		func(s, curr, Seek.SET)!;
		return len - curr;
	}
	return IoError.NOT_SEEKABLE?;
}

fn usz! Stream.read(Stream* s, char[] buffer)
{
	if (ReadStreamFn func = s.fns.read_fn) return func(s, buffer);
	if (ReadByteStreamFn func = s.fns.read_byte_fn)
	{
		usz len = 0;
		foreach (&cptr : buffer)
		{
			char! c = func(s);
			if (catch err = c)
			{
				case IoError.EOF: return len;
				default: return err?;
			}
			*cptr = c;
			len++;
		}
	}
	return IoError.UNSUPPORTED_OPERATION?;
}

fn char! Stream.read_byte(Stream* s) @inline
{
	if (ReadByteStreamFn func = s.fns.read_byte_fn) return func(s);
	return IoError.UNSUPPORTED_OPERATION?;
}

fn usz! Stream.write(Stream* s, char[] bytes) @inline
{
	if (WriteStreamFn func = s.fns.write_fn) return func(s, bytes);
	if (WriteByteStreamFn func = s.fns.write_byte_fn)
	{
		foreach (c : bytes) func(s, c)!;
		return bytes.len;
	}
	return IoError.UNSUPPORTED_OPERATION?;
}

fn void! Stream.write_byte(Stream* s, char b) @inline
{
	if (WriteByteStreamFn func = s.fns.write_byte_fn) return func(s, b);
	return IoError.UNSUPPORTED_OPERATION?;
}

fn usz! Stream.write_to(Stream* s, Stream* to) @inline
{
	if (WriteToStreamFn func = s.fns.write_stream_fn) return func(s, to);
	return IoError.UNSUPPORTED_OPERATION?;
}

fn usz! Stream.read_from(Stream* s, Stream* from) @inline
{
	if (ReadFromStreamFn func = s.fns.read_stream_fn) return func(s, from);
	return IoError.UNSUPPORTED_OPERATION?;
}

fn void! Stream.flush(Stream* s) @inline @maydiscard
{
	if (FlushStreamFn func = s.fns.flush_fn) return func(s);
	return IoError.UNSUPPORTED_OPERATION?;
}

fn usz! Stream.len(Stream* s) @inline
{
	if (LenStreamFn func = s.fns.len_fn) return func(s);
	if (SeekStreamFn func = s.fns.seek_fn)
	{
		usz curr = func(s, 0, Seek.CURSOR)!;
		usz len = func(s, 0, Seek.END)!;
		func(s, curr, Seek.SET)!;
		return len;
	}
	return IoError.NOT_SEEKABLE?;
}

fn void! Stream.pushback_byte(Stream* s) @inline
{
	if (PushbackByteStreamFn func = s.fns.pushback_byte_fn) return func(s);
	if (SeekStreamFn func = s.fns.seek_fn)
	{
		func(s, -1, CURSOR)!;
		return;
	}
	return IoError.UNSUPPORTED_OPERATION?;
}

fn void! Stream.write_string(Stream* s, String str) @inline => (void)(s.write((char[])str)!);

fn usz! Stream.copy_to(Stream* s, Stream* dst, char[] buffer = {})
{
	if (buffer.len) return copy_through_buffer(s, dst, buffer);
	if (WriteToStreamFn func = s.fns.write_stream_fn) return func(s, dst);
	if (ReadFromStreamFn func = dst.fns.read_stream_fn) return func(dst, s);
$switch (env::MEMORY_ENV)
$case NORMAL:
	@pool()
	{
		return copy_through_buffer(s, dst, tmalloc(char, 4096));
	};
$case SMALL:
	@pool()
	{
		return copy_through_buffer(s, dst, tmalloc(char, 1024));
	};
$case TINY:
$case NONE:
	return copy_through_buffer(s, dst, &&(char[256]{}));
$endswitch
}

macro usz! copy_through_buffer(Stream* s, Stream* dst, char[] buffer) @local
{
	usz total_copied;
	while (true)
	{
		usz! len = s.read(buffer);
		if (catch err = len)
		{
			case IoError.EOF: return total_copied;
			default: return err?;
		}
		if (!len) return total_copied;
		usz written = dst.write(buffer[:len])!;
		total_copied += len;
		if (written != len) return IoError.INCOMPLETE_WRITE?;
	}
}
module std::io::path;
import std::collections::list;

const PathEnv DEFAULT_PATH_ENV = env::os_is_win32() ? PathEnv.WIN32 : PathEnv.POSIX;
const char PREFERRED_SEPARATOR_WIN32 = '\\';
const char PREFERRED_SEPARATOR_POSIX = '/';
const char PREFERRED_SEPARATOR = env::os_is_win32() ? PREFERRED_SEPARATOR_WIN32 : PREFERRED_SEPARATOR_POSIX;

def PathList = List<Path>;

fault PathResult
{
	INVALID_PATH,
	NO_PARENT,
}

struct Path
{
	String path_string;
	PathEnv env;
}

enum PathEnv
{
	WIN32,
	POSIX
}


fn Path! getcwd(Allocator* using = mem::heap())
{
	@stack_mem(256; Allocator* mem)
	{
		return new(os::getcwd(mem), using);
	};
}

fn bool is_dir(Path path) => os::native_is_dir(path.as_str());
fn bool is_file(Path path) => os::native_is_file(path.as_str());
fn usz! file_size(Path path) => os::native_file_size(path.as_str());
fn bool exists(Path path) => os::native_file_or_dir_exists(path.as_str());
fn Path! tgetcwd() => getcwd(mem::temp()) @inline;
fn void! chdir(Path path) => os::native_chdir(path) @inline;
fn Path! temp_directory(Allocator* using = mem::heap()) => os::native_temp_directory(using);

macro bool is_separator(char c, PathEnv path_env = DEFAULT_PATH_ENV)
{
	return c == '/' || (c == '\\' && path_env == PathEnv.WIN32);
}

macro bool is_posix_separator(char c)
{
	return c == '/' || c == '\\';
}

macro bool is_win32_separator(char c)
{
	return c == '/' || c == '\\';
}

fn Path[]! ls(Path path)
{
	unreachable();
}

enum MkdirPermissions
{
	NORMAL,
	USER_ONLY,
	USER_AND_ADMIN
}



fn bool! mkdir(Path path, bool recursive = false, MkdirPermissions permissions = NORMAL)
{
	if (!path.path_string.len) return PathResult.INVALID_PATH?;
	if (is_dir(path)) return false;
	if (exists(path)) return IoError.FILE_NOT_DIR?;

	if (recursive)
	{
		if (try parent = path.parent()) mkdir(parent, true, permissions)!;
	}
	if (!is_dir(path.parent()) ?? false) return IoError.CANNOT_READ_DIR?;

	return os::native_mkdir(path, permissions);
}

fn bool! rmdir(Path path)
{
	if (!path.path_string.len) return PathResult.INVALID_PATH?;
	return os::native_rmdir(path);
}

fn void! rmtree(Path path)
{
	if (!path.path_string.len) return PathResult.INVALID_PATH?;
$if ($defined(os::native_rmtree))
	return os::native_rmtree(path);
$else
	assert(false, "rmtree is not available");
$endif
}

fn Path! new(String path, Allocator* using = mem::heap(), PathEnv path_env = DEFAULT_PATH_ENV)
{
	return { normalize(path.copy(using), path_env), path_env };
}

fn Path! new_windows(String path, Allocator* using = mem::heap())
{
	return new(path, using, WIN32);
}

fn Path! new_posix(String path, Allocator* using = mem::heap())
{
	return new(path, using, POSIX);
}

fn bool Path.equals(Path p1, Path p2)
{
	return p1.env == p2.env && p1.path_string == p2.path_string;
}

/**
 * Append the string to the current path.
 *
 * @param [in] path
 * @param [in] filename
 * @ensure return.path_string.len >= path.path_string.len
 **/
fn Path! Path.append(Path path, String filename, Allocator* using = mem::heap())
{
	if (!path.path_string.len) return new(filename, using, path.env)!;
	assert(!is_separator(path.path_string[^1], path.env));

	@stack_mem(256; Allocator* mem)
	{
		DString dstr = dstring::new_with_capacity(path.path_string.len + 1 + filename.len, .using = mem);
		dstr.append(path.path_string);
		dstr.append(PREFERRED_SEPARATOR);
		dstr.append(filename);
		return { normalize(dstr.copy_str(using), path.env), path.env };
	};
}

fn Path! Path.tappend(Path path, String filename) => path.append(filename, mem::temp());

fn usz Path.start_of_base_name(Path path) @local
{
	String path_str = path.path_string;
	if (!path_str.len) return 0;
	if (path.env == PathEnv.WIN32)
	{
		return path_str.rindex_of(`\`) + 1 ?? volume_name_len(path_str, path.env)!!;
	}
	return path_str.rindex_of("/") + 1 ?? 0;
}

fn String Path.basename(Path path)
{
	usz basename_start = path.start_of_base_name();
	String path_str = path.path_string;
	if (basename_start == path_str.len) return "";
	return path_str[basename_start..];
}

fn String Path.dirname(Path path)
{
	usz basename_start = path.start_of_base_name();
	String path_str = path.path_string;
	if (basename_start == 0) return "";
	usz start = volume_name_len(path_str, path.env)!!;
	if (basename_start <= start + 1) return path_str[:basename_start];
	return path_str[:basename_start - 1];
}

fn String! Path.extension(Path path)
{
	String basename = path.basename();
	usz index = basename.rindex_of(".")!;
	// Plain ".foo" does not have an
	if (index == 0) return SearchResult.MISSING?;
	if (index == basename.len) return "";
	return basename[index + 1..];
}

fn String Path.volume_name(Path path)
{
	usz len = volume_name_len(path.as_str(), path.env)!!;
	if (!len) return "";
	return path.path_string[:len];
}

fn usz! volume_name_len(String path, PathEnv path_env) @local
{
	usz len = path.len;
	if (len < 2 || path_env != PathEnv.WIN32) return 0;
	switch (path[0])
    {
    	case '\\':
    	    // "\\" paths.. must be longer than 2
    	    if (len == 2) return 0;
			int count = 1;
			while (count < len && path[count] == '\\') count++;
			// Not 2 => folded paths
			if (count != 2) return 0;
			// Check that we have a name followed by '/'
			for (usz i = 2; i < len; i++)
    		{
    		    char c = path[i];
    			if (is_win32_separator(c)) return i;
    			if (is_reserved_win32_path_char(c)) return PathResult.INVALID_PATH?;
    		}
    		return PathResult.INVALID_PATH?;
    	case 'A'..'Z':
    	case 'a'..'z':
    	    return path[1] == ':' ? 2 : 0;
    	default:
    	    return 0;
    }
}

fn Path! Path.parent(Path path)
{
	if (path.path_string.len == 1 && is_separator(path.path_string[0], path.env)) return PathResult.NO_PARENT?;
	foreach_r(i, c : path.path_string)
	{
		if (is_separator(c, path.env))
		{
			return { path.path_string[:i], path.env };
		}
	}
	return PathResult.NO_PARENT?;
}

fn String! normalize(String path_str, PathEnv path_env = DEFAULT_PATH_ENV)
{
	if (!path_str.len) return path_str;
    usz path_start = volume_name_len(path_str, path_env)!;
	usz path_len = path_str.len;
	if (path_start == path_len) return path_str;
	char path_separator = path_env == PathEnv.WIN32 ? PREFERRED_SEPARATOR_WIN32 : PREFERRED_SEPARATOR_POSIX;
	usz len = path_start;
	bool has_root = is_separator(path_str[path_start], path_env);
	if (has_root)
	{
		path_str[len++] = path_separator;
		path_start++;
	}
	// It is safe to write it as true, since we already dealt with /foo.
	// This allows us to avoid checking whether it is the start of the path.
	bool previous_was_separator = true;

	for (usz i = path_start; i < path_len; i++)
	{
		char c = path_str[i];
		// Fold foo///bar into foo/bar
		if (is_separator(c, path_env))
		{
			// Fold //
			if (previous_was_separator) continue;

			// New /, so mark and rewrite
			path_str.ptr[len++] = path_separator;
			previous_was_separator = true;
			continue;
		}

		// The rest are names of the path elements, so check that the
		// characters are valid.
		if (is_reserved_path_char(c, path_env)) return PathResult.INVALID_PATH?;

		// If we have '.' after a separator
		if (c == '.' && previous_was_separator)
		{
			// Get the number of dots until next separator, expecting 1 or 2
			bool is_last = i == path_len - 1;
			int dots = 1;
			if (!is_last && path_str[i + 1] == '.')
			{
				dots = 2;
				is_last = i == path_len - 2;
				if (!is_last && !is_separator(path_str[i + 2], path_env))
				{
					dots = 0;
				}
			}
			switch (dots)
			{
				case 1:
					// /./abc -> skip to /./abc
					//  ^                  ^
					i++;
					continue;
				case 2:
					// This is an error: /a/../..
					if (len == path_start && has_root) return PathResult.INVALID_PATH?;

					// If this .. at the start, or after ../? If so, we just copy ..
					if (len == path_start ||
						(len - path_start >= 3 && path_str[len - 1] == path_separator
						&& path_str[len - 3] == '.' && path_str[len - 3] == '.' &&
						(len - 3 == 0 || path_str[len - 4] == path_separator)))
					{
						if (i != len)
						{
							path_str[len] = '.';
							path_str[len + 1] = '.';
						}
						len += 2;
						if (len < path_len) path_str[len++] = path_separator;
						i += 2;
						continue;
					}
					// Step back, now looking at '/' abc/def/. -> abc/def/
					len--;
					// Step back until finding a separator or the start.
					while (len > path_start && !is_separator(path_str[len - 1], path_env))
					{
						len--;
					}
					// Reading, we go from /../abc to /../abc
					//                      ^            ^
 					i += 2;
					continue;
				default:
					break;

			}
		}
		if (i != len) path_str[len] = c;
		previous_was_separator = false;
		len++;
	}
	if (len > path_start + 1 && is_separator(path_str[len - 1], path_env)) len--;
	path_str.ptr[len] = 0;
	return path_str[:len];
}

fn ZString Path.as_zstr(Path path) => (ZString)path.path_string.ptr;

fn String Path.root_directory(Path path)
{
	String path_str = path.as_str();
	usz len = path_str.len;
	if (!len) return "";
	if (path.env == PathEnv.WIN32)
	{
		usz root_len = volume_name_len(path_str, path.env)!!;
		if (root_len == len || !is_win32_separator(path_str[root_len])) return "";
		return path_str[root_len..root_len];
	}
	if (!is_posix_separator(path_str[0])) return "";
	for (usz i = 1; i < len; i++)
	{
		if (is_posix_separator(path_str[i]))
		{
			return path_str[:i];
		}
	}
	return path_str;
}


fn String Path.as_str(Path path)
{
	return path.path_string;
}


fn bool Path.has_suffix(Path path, String str)
{
	return path.as_str().ends_with(str);
}


fn void Path.free(Path path)
{
	free(path.path_string.ptr);
}


const bool[256] RESERVED_PATH_CHAR_POSIX = {
	[0] = true,
	['/'] = true,
};
const bool[256] RESERVED_PATH_CHAR_WIN32 = {
	[0..31] = true,
	['>'] = true,
	['<'] = true,
	[':'] = true,
	['\"'] = true,
	['/'] = true,
	['\\'] = true,
	['|'] = true,
	['?'] = true,
	['*'] = true,
};

macro bool is_reserved_win32_path_char(char c)
{
	return RESERVED_PATH_CHAR_WIN32[c];
}

macro bool is_reserved_path_char(char c, PathEnv path_env = DEFAULT_PATH_ENV)
{
	return path_env == PathEnv.WIN32
		? RESERVED_PATH_CHAR_WIN32[c]
		: RESERVED_PATH_CHAR_POSIX[c];
}

module libc::os;


$switch

$case env::COMPILER_LIBC_AVAILABLE && env::OS_TYPE == LINUX:

extern fn int* __errno_location();
macro int errno() => *__errno_location();
macro void errno_set(int err) => *(__errno_location()) = err;

$case env::COMPILER_LIBC_AVAILABLE && env::OS_TYPE == MACOS:

extern fn int* __error();
macro int errno() => *__error();
macro void errno_set(int err) => *(__error()) = err;

$case env::COMPILER_LIBC_AVAILABLE && env::OS_TYPE == WIN32:

macro int errno()
{
	int holder;
	_get_errno(&holder);
	return holder;
}

macro void errno_set(int err) => _set_errno(err);

extern fn void _get_errno(int* result);
extern fn void _set_errno(int err);

$default:

tlocal int _errno_c3 = 0;
fn void errno_set(int err) => _errno_c3 = err;
fn int errno() => _errno_c3;

$endswitch
// Copyright (c) 2021 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module libc;


// Constants need to be per os/arch
const int EXIT_FAILURE = 1;
const int EXIT_SUCCESS = 0;
const int RAND_MAX = 0x7fffffff;

struct DivResult
{
    int quot;
    int rem;
}

struct LongDivResult
{
    long quot;
    long rem;
}

fn Errno errno()
{
	return (Errno)os::errno();
}

fn void errno_set(Errno e)
{
	os::errno_set((int)e);
}

def TerminateFunction = fn void();
def CompareFunction = fn int(void*, void*);
def JmpBuf = uptr[$$JMP_BUF_SIZE];

$if (env::COMPILER_LIBC_AVAILABLE)

extern fn double atof(char* str);
extern fn int atoi(char* str);
extern fn CLongLong atoll(char* str);
extern fn double strtod(char* str, char** endptr);
extern fn CLong strtol(char* str, char** endptr, int base);
extern fn CULong stroul(char* str, char** endptr, int base);
extern fn void abort();
extern fn void atexit(TerminateFunction f);
extern fn void exit(int status);
extern fn ZString getenv(ZString name);
extern fn int setenv(ZString name, ZString value, int overwrite);
extern fn int unsetenv(ZString name);
extern fn int system(char* str);
extern fn void bsearch(void* key, void *base, usz items, usz size, CompareFunction compare);
extern fn void qsort(void* base, usz items, usz size, CompareFunction compare);
extern fn DivResult div(int numer, int denom);
extern fn long labs(long x);
extern fn LongDivResult ldiv(long number, long denom);
extern fn int rand();
extern fn void srand(uint seed);

extern fn void longjmp(JmpBuf* buffer, CInt value);
$if (env::os_is_win32())
// TODO win32 aarch64
extern fn CInt _setjmp(void* frameptr, JmpBuf* buffer);
macro CInt setjmp(JmpBuf* buffer) => _setjmp($$frameaddress(), buffer);
$else
extern fn CInt setjmp(JmpBuf* buffer);
$endif
// MB functions omitted

// string
extern fn void* memchr(void* str, int c, usz n);
extern fn int memcmp(void* str1, void* str2, usz n);
extern fn void* memcpy(void* dest, void* src, usz n);
extern fn void* memmove(void* dest, void* src, usz n);
extern fn void* memset(void* dest, CInt value, usz n);
extern fn char* strcat(char* dest, char* src);
extern fn char* strncat(char* dest, char* src, usz n);
extern fn char* strchr(char* str, int c);
extern fn int strcmp(char* str1, char* str2);
extern fn int strncmp(char* str1, char* str2, usz n);
extern fn int strcoll(char* str1, char* str2);
extern fn char* strcpy(char* dst, char* src);
extern fn char* strncpy(char* dst, char* src, usz n);
extern fn usz strcspn(char* str1, char* str2);
extern fn char* strerror(int errn);
extern fn usz strlen(char* str);
extern fn char* strpbrk(char* str1, char* str2);
extern fn usz strspn(char* str1, char* str2);
extern fn char* strstr(char* haystack, char* needle);
extern fn char* strtok(char* str, char* delim);
extern fn usz strxfrm(char* dest, char* src, usz n);

// malloc
extern fn void* malloc(usz size);
extern fn void* calloc(usz count, usz size);
extern fn void* free(void*);
extern fn void* realloc(void* ptr, usz size);

$else

fn void longjmp(JmpBuf* buffer, CInt value) @weak @extern("longjmp") @nostrip
{
	unreachable("longjmp unavailable");
}

fn CInt setjmp(JmpBuf* buffer) @weak @extern("setjmp") @nostrip
{
	unreachable("setjmp unavailable");
}

fn void* malloc(usz size) @weak @extern("malloc") @nostrip
{
	unreachable("malloc unavailable");
}
fn void* calloc(usz count, usz size) @weak @extern("calloc") @nostrip
{
	unreachable("calloc unavailable");
}
fn void* free(void*) @weak @extern("free")
{
	unreachable("free unavailable");
}

fn void* realloc(void* ptr, usz size) @weak @extern("realloc") @nostrip
{
	unreachable("realloc unavailable");
}

fn void* memcpy(void* dest, void* src, usz n) @weak @extern("memcpy") @nostrip
{
	for (usz i = 0; i < n; i++) ((char*)dest)[i] = ((char*)src)[i];
	return dest;
}

fn void* memmove(void* dest, void* src, usz n) @weak @extern("memmove") @nostrip
{
	return memcpy(dest, src, n) @inline;
}

fn void* memset(void* dest, CInt value, usz n) @weak @extern("memset") @nostrip
{
	for (usz i = 0; i < n; i++) ((char*)dest)[i] = (char)value;
	return dest;
}

$endif

// stdio

def Fpos = long;
def CFile = void*;

$switch
$case env::COMPILER_LIBC_AVAILABLE && env::OS_TYPE == LINUX:
    extern CFile __stdin @extern("stdin");
    extern CFile __stdout @extern("stdout");
    extern CFile __stderr @extern("stderr");
    extern fn usz malloc_usable_size(void* ptr);
    macro usz malloc_size(void* ptr) { return malloc_usable_size(ptr); }
	extern fn void* aligned_alloc(usz align, usz size);
    macro CFile stdin() { return __stdin; }
    macro CFile stdout() { return __stdout; }
    macro CFile stderr() { return __stderr; }
$case env::COMPILER_LIBC_AVAILABLE && env::os_is_darwin():
    extern CFile __stdinp;
    extern CFile __stdoutp;
    extern CFile __stderrp;
    extern fn usz malloc_size(void* ptr);
    extern fn void* aligned_alloc(usz align, usz size);
	macro CFile stdin() { return __stdinp; }
    macro CFile stdout() { return __stdoutp; }
    macro CFile stderr() { return __stderrp; }
$case env::COMPILER_LIBC_AVAILABLE && env::os_is_win32():
    extern fn CFile __acrt_iob_func(CInt c);
    extern fn usz _msize(void* ptr);
    macro usz malloc_size(void* ptr) { return _msize(ptr); }
    macro CFile stdin() { return __acrt_iob_func(0); }
    macro CFile stdout() { return __acrt_iob_func(1); }
    macro CFile stderr() { return __acrt_iob_func(2); }
$default:
    macro CFile stdin() { return (CFile*)(uptr)0; }
    macro CFile stdout() { return (CFile*)(uptr)1; }
    macro CFile stderr() { return (CFile*)(uptr)2; }
$endswitch

const HAS_MALLOC_SIZE =
	env::OS_TYPE == LINUX
	|| env::os_is_win32()
	|| env::os_is_darwin();

// The following needs to be set per arch+os
// For now I have simply pulled the defaults from MacOS
const int SEEK_SET = 0;
const int SEEK_CUR = 1;
const int SEEK_END = 2;
const int _IOFBF = 0; // Fully buffered
const int _IOLBF = 1; // Line buffered
const int _IONBF = 2; // Unbuffered
const int BUFSIZ = 1024;
const int EOF = -1;
const int FOPEN_MAX = 20;
const int FILENAME_MAX = 1024;

def Errno = distinct CInt;
def SeekIndex = CLong;

$if (env::COMPILER_LIBC_AVAILABLE)

extern fn int fclose(CFile stream);
extern fn void clearerr(CFile stream);
extern fn int feof(CFile stream);
extern fn int ferror(CFile stream);
extern fn int fflush(CFile stream);
extern fn int fgetpos(CFile stream, Fpos* pos);
extern fn CFile fopen(ZString filename, ZString mode);
extern fn usz fread(void* ptr, usz size, usz nmemb, CFile stream);
extern fn CFile freopen(ZString filename, ZString mode, CFile stream);
extern fn CFile fmemopen(void* ptr, usz size, ZString mode);
extern fn int fseek(CFile stream, SeekIndex offset, int whence);
extern fn int fsetpos(CFile stream, Fpos* pos);
extern fn SeekIndex ftell(CFile stream);
extern fn usz fwrite(void* ptr, usz size, usz nmemb, CFile stream);
extern fn int remove(char* filename);
extern fn int rename(char* old_name, char* new_name);
extern fn void rewind(CFile stream);
extern fn void setbuf(CFile stream, char* buffer);
extern fn void setvbuf(CFile stream, char* buffer, int mode, usz size);
extern fn CFile tmpnam(char* str);
extern fn int fprintf(CFile stream, char* format, ...);
extern fn int printf(char* format, ...);
extern fn int sprintf(char* str, char* format, ...);
extern fn int snprintf(char* str, usz size, char* format, ...);
extern fn int fscanf(CFile stream, char* format, ...);
extern fn int scanf(char* format, ...);
extern fn int sscanf(char* str, char* format, ...);
extern fn int fgetc(CFile stream);
extern fn char* fgets(char* str, int n, CFile stream);
extern fn int fputc(int c, CFile stream);
extern fn int getc(CFile stream);
extern fn int getchar();
extern fn int putc(int c, CFile stream);
extern fn int putchar(int c);
extern fn int puts(char* str);
extern fn int ungetc(int c, CFile stream);
extern fn void perror(char* str);
extern fn isz getline(char** linep, usz* linecapp, CFile stream);

$else

fn int fseek(CFile stream, SeekIndex offset, int whence) @weak @extern("fseek") @nostrip
{
	unreachable("'fseek' not available.");
}
fn CFile fopen(ZString filename, ZString mode) @weak @extern("fopen") @nostrip
{
	unreachable("'fopen' not available.");
}

fn CFile freopen(ZString filename, ZString mode, CFile stream) @weak @extern("fopen") @nostrip
{
	unreachable("'freopen' not available.");
}

fn usz fwrite(void* ptr, usz size, usz nmemb, CFile stream) @weak @extern("fwrite") @nostrip
{
	unreachable("'fwrite' not available.");
}

fn usz fread(void* ptr, usz size, usz nmemb, CFile stream) @weak @extern("fread") @nostrip
{
	unreachable("'fread' not available.");
}

fn CFile fclose(CFile) @weak @extern("fclose") @nostrip
{
	unreachable("'fclose' not available.");
}

fn int fflush(CFile stream) @weak @extern("fflush") @nostrip
{
	unreachable("'fflush' not available.");
}

fn int fputc(int c, CFile stream) @weak @extern("fputc") @nostrip
{
	unreachable("'fputc' not available.");
}

fn char* fgets(ZString str, int n, CFile stream) @weak @extern("fgets") @nostrip
{
	unreachable("'fgets' not available.");
}

fn int fgetc(CFile stream) @weak @extern("fgetc") @nostrip
{
	unreachable("'fgetc' not available.");
}

fn int feof(CFile stream) @weak @extern("feof") @nostrip
{
	unreachable("'feof' not available.");
}

fn int putc(int c, CFile stream) @weak @extern("putc") @nostrip
{
	unreachable("'putc' not available.");
}
fn int putchar(int c) @weak @extern("putchar") @nostrip
{
	unreachable("'putchar' not available.");
}
fn int puts(ZString str) @weak @extern("puts") @nostrip
{
	unreachable("'puts' not available.");
}

$endif
// vsprintf vprintf not supported

// time.h

struct TmCommon @private
{
	int	tm_sec;		/* seconds after the minute [0-60] */
	int	tm_min;		/* minutes after the hour [0-59] */
	int	tm_hour;	/* hours since midnight [0-23] */
	int	tm_mday;	/* day of the month [1-31] */
	int	tm_mon;		/* months since January [0-11] */
	int	tm_year;	/* years since 1900 */
	int	tm_wday;	/* days since Sunday [0-6] */
	int	tm_yday;	/* days since January 1 [0-365] */
	int	tm_isdst;	/* Daylight Savings Time flag */
}


$switch (env::OS_TYPE)

$case WIN32:

def Tm = TmCommon;

$case WASI:

def TimeOffset = int;
struct Tm
{
	inline TmCommon common;
	TimeOffset tm_gmtoff;	/* offset from UTC in seconds */
    char *tm_zone;	/* timezone abbreviation */
    int tm_nsec;
}

$case MACOS:
$case IOS:
$case TVOS:
$case WATCHOS:
$case OPENBSD:
$case FREEBSD:
$default:

def TimeOffset = CLong;
struct Tm
{
	inline TmCommon common;
	TimeOffset tm_gmtoff;	/* offset from UTC in seconds */
    char *tm_zone;	/* timezone abbreviation */
}

$endswitch


$if (env::os_is_win32())

struct TimeSpec
{
	Time_t s;
	ulong ns;
}

def Time_t = long;
def Clock_t = ulong;

$else

struct TimeSpec
{
	Time_t s;
	CLong ns;
}

def Time_t = CLong;
def Clock_t = CULong;

$endif

const int TIME_UTC = 1;

extern fn int timespec_get(TimeSpec* ts, int base);
extern fn int nanosleep(TimeSpec* req, TimeSpec* remaining);

// Likely wrong, must be per platform.
const CLOCKS_PER_SEC = 1000000;


extern fn ZString asctime(Tm *timeptr);
extern fn Clock_t clock();
extern fn ZString ctime(Time_t *timer);
extern fn double difftime(Time_t time1, Time_t time2);
extern fn Tm* gmtime(Time_t *timer);

extern fn Tm* localtime(Time_t *timer);

$if (env::os_is_win32())
extern fn Tm* _gmtime64_s(Tm* buf, Time_t *timer);
extern fn Tm* _localtime64_s(Tm* buf, Time_t *timer);
extern fn void _get_timezone(CLong *timezone);

macro Tm* gmtime_r(Time_t *timer, Tm* buf) => _gmtime64_s(buf, timer);
macro Tm* localtime_r(Time_t *timer, Tm* buf) => _localtime64_s(buf, timer);

extern fn Time_t mktime(Tm *timeptr) @extern("_mktime64");
extern fn Time_t timegm(Tm *timeptr) @extern("_mkgmtime64");
$else
extern fn Tm* gmtime_r(Time_t *timer, Tm* buf);
extern fn Tm* localtime_r(Time_t *timer, Tm* buf);
extern fn Time_t mktime(Tm *timeptr);
extern fn Time_t timegm(Tm *timeptr);
$endif

extern fn usz strftime(char* str, usz maxsize, char* format, Tm *timeptr);
extern fn Time_t time(Time_t *timer);

// signal
def SignalFunction = fn void(int);
extern fn SignalFunction signal(int sig, SignalFunction function);
// Incomplete


module libc::errno;

const Errno OK = 0;
const Errno EPERM = 1;      // Operation not permitted
const Errno ENOENT = 2;     // No such file or directory
const Errno ESRCH = 3;      // No such process
const Errno EINTR = 4;      // Interrupted system call
const Errno EIO = 5;        // I/O error
const Errno ENXIO = 6;      // No such device or address
const Errno E2BIG = 7;      // Argument list too long
const Errno ENOEXEC = 8;    // Exec format error
const Errno EBADF = 9;      // Bad file number
const Errno ECHILD = 10;    // No child processes

$if (env::OS_TYPE == MACOS)
const Errno EAGAIN = 35;    // Try again Macos
$else
const Errno EAGAIN = 11;    // Try again
$endif

const Errno ENOMEM = 12;    // Out of memory
const Errno EACCES = 13;    // Permission denied
const Errno EFAULT = 14;    // Bad address
const Errno ENOTBLK = 15;   // Block device required, not on Win32
const Errno EBUSY = 16;     // Device or resource busy
const Errno EEXIST = 17;    // File exists
const Errno EXDEV = 18;     // Cross-device link
const Errno ENODEV = 19;    // No such device
const Errno ENOTDIR = 20;   // Not a directory
const Errno EISDIR = 21;    // Is a directory
const Errno EINVAL = 22;    // Invalid argument
const Errno ENFILE = 23;    // File table overflow
const Errno EMFILE = 24;    // Too many open files
const Errno ENOTTY = 25;    // Not a typewriter
const Errno ETXTBSY = 26;   // Text file busy, not on Win32
const Errno EFBIG = 27;     // File too large
const Errno ENOSPC = 28;    // No space left on device
const Errno ESPIPE = 29;    // Illegal seek
const Errno EROFS = 30;     // Read-only file system
const Errno EMLINK = 31;    // Too many links
const Errno EPIPE = 32;     // Broken pipe
const Errno EDOM = 33;      // Math argument out of domain of func
const Errno ERANGE = 34;    // Math result not representable

$switch (env::OS_TYPE)

$case MACOS:
const Errno EDEADLK = 11;       // Resource deadlock would occur MacOS
const Errno ENAMETOOLONG = 63;  // File name too long MacOS
const Errno ELOOP = 62;         // Too many symbolic links encountered
const Errno EOVERFLOW = 84;     // Value too large for defined data type Macos
const Errno ECONNRESET = 54;    // Connection reset by peer Macos
const Errno ENETDOWN = 50;      // Network is down MacOS
const Errno ENETUNREACH = 51;   // Network is unreachable MacOS
const Errno ENETRESET = 52;     // Network dropped connection because of reset MacOS
const Errno EOPNOTSUPP = 45;    // Operation not supported on transport endpoint
const Errno ENOTEMPTY = 66;     // Directory not empty

$case WIN32:
const Errno EDEADLK = 36;       // Resource deadlock would occur Win32
const Errno ENAMETOOLONG = 38;  // File name too long Win32
const Errno ELOOP = 114;        // Too many symbolic links encountered
const Errno EOVERFLOW = 132;    // Value too large for defined data type
const Errno ENETDOWN = 116;     // Network is down
const Errno ECONNRESET = 108;   // Connection reset by peer
const Errno ENETUNREACH = 118;  // Network is unreachable
const Errno ENETRESET = 117;    // Network dropped connection because of reset
const Errno EOPNOTSUPP = 130;   // Operation not supported on transport endpoint
const Errno ENOTEMPTY = 41;     // Directory not empty

$default:
const Errno EDEADLK = 35;       // Resource deadlock would occur Linux (others?)
const Errno ENAMETOOLONG = 36;  // File name too long Linux (others?)
const Errno ELOOP = 40;         // Too many symbolic links encountered
const Errno EOVERFLOW = 75;     // Value too large for defined data type
const Errno ENETDOWN = 100;     // Network is down
const Errno ECONNRESET = 104;   // Connection reset by peer
const Errno ENETUNREACH = 101;  // Network is unreachable
const Errno ENETRESET = 102;    // Network dropped connection because of reset
const Errno EOPNOTSUPP = 95;    // Operation not supported on transport endpoint
const Errno ENOTEMPTY = 39;     // Directory not empty

$endswitch



/*
const Errno ENOLCK = 37;  /* No record locks available */
const Errno ENOSYS = 38;  /* Function not implemented */

const Errno ENOMSG = 42;  /* No message of desired type */
const Errno EIDRM = 43;  /* Identifier removed */
const Errno ECHRNG = 44;  /* Channel number out of range */
const Errno EL2NSYNC = 45;  /* Level 2 not synchronized */
const Errno EL3HLT = 46;  /* Level 3 halted */
const Errno EL3RST = 47;  /* Level 3 reset */
const Errno ELNRNG = 48;  /* Link number out of range */
const Errno EUNATCH = 49;  /* Protocol driver not attached */
const Errno ENOCSI = 50;  /* No CSI structure available */
const Errno EL2HLT = 51;  /* Level 2 halted */
const Errno EBADE = 52;  /* Invalid exchange */
const Errno EBADR = 53;  /* Invalid request descriptor */
const Errno EXFULL = 54;  /* Exchange full */
const Errno ENOANO = 55;  /* No anode */
const Errno EBADRQC = 56;  /* Invalid request code */
const Errno EBADSLT = 57;  /* Invalid slot */

const Errno EBFONT = 59;  /* Bad font file format */
const Errno ENOSTR = 60;  /* Device not a stream */
const Errno ENODATA = 61;  /* No data available */
const Errno ETIME = 62;  /* Timer expired */
const Errno ENOSR = 63;  /* Out of streams resources */
const Errno ENONET = 64;  /* Machine is not on the network */
const Errno ENOPKG = 65;  /* Package not installed */
const Errno EREMOTE = 66;  /* Object is remote */
const Errno ENOLINK = 67;  /* Link has been severed */
const Errno EADV = 68;  /* Advertise error */
const Errno ESRMNT = 69;  /* Srmount error */
const Errno ECOMM = 70;  /* Communication error on send */
const Errno EPROTO = 71;  /* Protocol error */
const Errno EMULTIHOP = 72;  /* Multihop attempted */
const Errno EDOTDOT = 73;  /* RFS specific error */
const Errno EBADMSG = 74;  /* Not a data message */
const Errno ENOTUNIQ = 76;  /* Name not unique on network */
const Errno EBADFD = 77;  /* File descriptor in bad state */
const Errno EREMCHG = 78;  /* Remote address changed */
const Errno ELIBACC = 79;  /* Can not access a needed shared library */
const Errno ELIBBAD = 80;  /* Accessing a corrupted shared library */
const Errno ELIBSCN = 81;  /* .lib section in a.out corrupted */
const Errno ELIBMAX = 82;  /* Attempting to link in too many shared libraries */
const Errno ELIBEXEC = 83;  /* Cannot exec a shared library directly */
const Errno EILSEQ = 84;  /* Illegal byte sequence */
const Errno ERESTART = 85;  /* Interrupted system call should be restarted */
const Errno ESTRPIPE = 86;  /* Streams pipe error */
const Errno EUSERS = 87;  /* Too many users */
const Errno ENOTSOCK = 88;  /* Socket operation on non-socket */
const Errno EDESTADDRREQ = 89;  /* Destination address required */
const Errno EMSGSIZE = 90;  /* Message too long */
const Errno EPROTOTYPE = 91;  /* Protocol wrong type for socket */
const Errno ENOPROTOOPT = 92;  /* Protocol not available */
const Errno EPROTONOSUPPORT = 93;  /* Protocol not supported */
const Errno ESOCKTNOSUPPORT = 94;  /* Socket type not supported */
const Errno EPFNOSUPPORT = 96;  /* Protocol family not supported */
const Errno EAFNOSUPPORT = 97;  /* Address family not supported by protocol */
const Errno EADDRINUSE = 98;  /* Address already in use */
const Errno EADDRNOTAVAIL = 99;  /* Cannot assign requested address */
const Errno ECONNABORTED = 103; /* Software caused connection abort */
const Errno ENOBUFS = 105; /* No buffer space available */
const Errno EISCONN = 106; /* Transport endpoint is already connected */
const Errno ENOTCONN = 107; /* Transport endpoint is not connected */
const Errno ESHUTDOWN = 108; /* Cannot send after transport endpoint shutdown */
const Errno ETOOMANYREFS = 109; /* Too many references: cannot splice */
const Errno ECONNREFUSED = 111; /* Connection refused */
const Errno EHOSTDOWN = 112; /* Host is down */
const Errno EHOSTUNREACH = 113; /* No route to host */
*/

$switch (env::OS_TYPE)

$case MACOS:
const Errno ETIMEDOUT = 60;     // Connection timed out
const Errno EINPROGRESS = 36;   // Operation now in progress MacOS
const Errno EALREADY = 37;      // Operation already in progress MacOS
const Errno EDQUOT = 69;        // Quota exceeded, MacOS
const Errno EWOULDBLOCK = 35;   // Operation would block

$case WIN32:
const Errno ETIMEDOUT = 138;    // Connection timed out
const Errno EALREADY = 103;     // Operation already in progress
const Errno EINPROGRESS = 112;  // Operation now in progress Win32
const Errno EDQUOT = -122;      // Quota exceeded, not in Win32
const Errno EWOULDBLOCK = 140;  // Operation would block

$default:
const Errno ETIMEDOUT = 110;    // Connection timed out
const Errno EALREADY = 114;     // Operation already in progress
const Errno EINPROGRESS = 115;  // Operation now in progress
const Errno EDQUOT = 122;       // Quota exceeded
const Errno EWOULDBLOCK = 41;   // Operation would block
$endswitch

/*
const Errno ESTALE = 116; /* Stale NFS file handle */
const Errno EUCLEAN = 117; /* Structure needs cleaning */
const Errno ENOTNAM = 118; /* Not a XENIX named type file */
const Errno ENAVAIL = 119; /* No XENIX semaphores available */
const Errno EISNAM = 120; /* Is a named type file */
const Errno EREMOTEIO = 121; /* Remote I/O error */

const Errno ENOMEDIUM = 123; /* No medium found */
const Errno EMEDIUMTYPE = 124; /* Wrong medium type */
const Errno ECANCELED = 125; /* Operation Canceled */
const Errno ENOKEY = 126; /* Required key not available */
const Errno EKEYEXPIRED = 127; /* Key has expired */
const Errno EKEYREVOKED = 128; /* Key has been revoked */
const Errno EKEYREJECTED = 129; /* Key was rejected by service */

const Errno EOWNERDEAD = 130; /* Owner died */
const Errno ENOTRECOVERABLE = 131; /* State not recoverable */
*/
module std::math::nolibc;

$if (!env::COMPILER_LIBC_AVAILABLE)

/* origin: FreeBSD /usr/src/lib/msun/src/k_cos.c */
/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunSoft, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */

fn double __cos(double x, double y) @extern("__cos") @weak @nostrip
{
	const C1 =  4.16666666666666019037e-02; /* 0x3FA55555, 0x5555554C */
	const C2 = -1.38888888888741095749e-03; /* 0xBF56C16C, 0x16C15177 */
	const C3 =  2.48015872894767294178e-05; /* 0x3EFA01A0, 0x19CB1590 */
	const C4 = -2.75573143513906633035e-07; /* 0xBE927E4F, 0x809C52AD */
	const C5 =  2.08757232129817482790e-09; /* 0x3E21EE9E, 0xBDB4B1C4 */
	const C6 = -1.13596475577881948265e-11; /* 0xBDA8FAE9, 0xBE8838D4 */

	double z = x * x;
	double w = z * z;
	double r = z * (C1 + z * (C2 + z * C3)) + w * w * (C4 + z * (C5 + z * C6));
	double hz = 0.5 * z;
	w = 1.0 - hz;
	return w + (((1.0 - w) - hz) + (z * r - x * y));
}

$endif