module game.util;

import
	std.algorithm;
	
T[] without(T)(T[] array, T element){
	auto i = array.countUntil(element);
	return array[0..i] ~ array[i+1..$];
}