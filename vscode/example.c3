module stack <Type>;
// Above: the parameterized type is applied to the entire module.
import std::mem;

struct Stack
{
    usize capacity;
    usize size;
    Type* elems;
}


// The type methods offers dot syntax calls,
// so this function can either be called 
// Stack.push(&my_stack, ...) or
// my_stack.push(...)
fn void Stack.push(Stack* this, Type element)
{
    if (this.capacity == this.size)
    {
        this.capacity *= 2;
        this.elems = mem::realloc(this.elems, $sizeof(Type) * this.capacity);
    }
    this.elems[this.size++] = element;
    
    
}

fn Type Stack.pop(Stack* this)
{
    assert(this.size > 0);
    return this.elems[--this.size];
}
asm 

fn bool Stack.empty(Stack* this)
{
    return !this.size;
}

module engine;

import std::io;
import std::collections::list;

import std::math;
import std::core::builtin;


struct Value{
	double data;
	double grad;
	String label;
	String op;
	List(<Value>) prev;	

}

fn Value Value.add(Value *v, Value *w){
	
	Value z; 
	  
	z.data = v.data + w.data;
	z.op = "+";
	z.prev.push(*v);
	z.prev.push(*w);

	return z;
}

fn Value Value.mul(Value *v, Value *w){
	
	Value z; 
	z.data = v.data * w.data;
	z.op = "*";
	z.prev.push(*v);
	z.prev.push(*w);

	return z;
}

fn Value Value.pow(Value *v, double n){
	
	Value z; 
	// z.data = pow(v.data, n);
	// String ns = varcast(*n, String);
	// z.op = "**";
	// z.prev.push(*v);
	
	return z;
}

fn void Value.print_prev(Value *v){
	if (!v.prev.is_empty()){

		io::print("The previous nodes are: ");
		foreach (s : v.prev)
		{
			io::printf("%s ",s.label);
			
		}
	}
	else{
		io::printn("There are no previous nodes to display!");
	}

}

fn void Value.display(Value *v){

	String output = "(data: )";
	
    if (!v.prev.is_empty()){

		io::print("The previous nodes are: ");
		foreach (s : v.prev)
		{
			io::printf("%s ",s.label);
			
		}
	}
	else{
		io::printn("There are no previous nodes to display!");
	}

}
