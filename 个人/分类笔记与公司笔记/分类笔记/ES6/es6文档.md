
    var a = 3;
引用变量 : 模板字符串 `${a}`  html:  `hello ${a}`
let 块级变量 在{}有效  const 不可变常量  必须在定义之后引用,不允许重复定义
  (x => x * 2)(1);
var json={a:2,b:4};  map使用 for of
for(var i in json){
    console.log(i,json[i]);
}

var a = [[1, 2], [3, 4]].map(([a, b]) => a + b);  a=[3,7]
var b = [1, undefined, 3].map((x = 'yes') => x);  b = [ 1, 'yes', 3 ]   =>必须为undifine
let { id, status, data: number } = 
{
id: 42,
status: "OK",
data: [867, 5309]
};        
      id=42, status="OK", number=[867, 5309]

全局属性    window.a = 1; window.a=a; 或者 a = 2; window.a=a;  不能用let const定义
直接赋值 let [foo, [[bar], baz]] = [1, [[2], 3]];
解构     let [ , , third] = ["foo", "bar", "baz"];        third = "baz"
         let [x, , y] = [1, 2, 3];                        x=1  y=3
         let [head, ...tail] = [1, 2, 3, 4];              head=1  tail=4
         var { foo, bar } = { foo: "aaa", bar: "bbb" };   foo = "aaa" bar="bbb"
         let { first: f, last: l } = { first: 'hello', last: 'world' }  f = 'hello' l = 'world'
         let {length : len} = 'hello';                    len=5

"\u{20BB7}"  吉      let hello = 123;  hell\u{6F}=123
includes(),startsWith(),endsWith() 返回布尔值   repeat()
'x'.padStart(5, 'ab')  补全  ababx     '09-12'.padStart(10, 'YYYY-MM-DD')= "YYYY-09-12"
'x'.padEnd(4, 'ab') = 'xaba' 'xxx'.padEnd(2, 'ab')= 'xxx'

函数设置默认值 
function log(x, y = 'World')  填充 new Array(3).fill('a') => ["a","a","a"]
[,'a'].forEach((x,i) => console.log(i)); => 1
[1, 2, 3].includes(2); => true
[1, 2, 3].includes(3, -1); => true  -1代表倒数


Array.prototype.copyWithin(target, start = 0, end = this.length)
target （必需）：从该位置开始替换数据。
start （可选）：从该位置开始读取数据，默认为 0 。如果为负值，表示倒数。
end （可选）：到该位置前停止读取数据，默认等于数组长度。如果为负值，表示倒数。

[1, 2, 3, 4, 5].copyWithin(0, 3)  => [4, 5, 3, 4, 5]   从0开始替换, 从第3位开始拿值

2.find() 和 findIndex()
[1, 4, -5, 10].find((n) => n < 0)  => -5
[1, 5, 10, 15].find(function(value, index, arr) {
return value > 9;
}) => 10
findIndex() 同理 寻找下标

3.数组实例的 entries() ， keys() 和 values()
for (let index of ['a', 'b'].keys()) {
console.log(index);
}
=> 0
=> 1
for (let elem of ['a', 'b'].values()) {
console.log(elem);
}
=> 'a'
=> 'b'
for (let [index, elem] of ['a', 'b'].entries()) {
console.log(index, elem);
}
=> 0 "a"
=> 1 "b

5.数组includes()
[1, 2, 3].includes(2); => true
[1, 2, 3].includes(3, -1); => true  比如第二个参数为 -4 ，但数组长度为 3 则从 0 开始

6.函数的 length 属性
函数的length属性，将返回没有指定默认值的参数个数。也就是说，指定了默认值后，length属性将失真
(function (a = 5) {}).length => 0
(function (a, b, c = 5) {}).length => 2
如果设置了默认值的参数不是尾参数，那么length属性也不再计入后面的参数了。
(function (a = 0, b, c) {}).length => 0
(function (a, b = 1, c) {}).length => 1

7.作用域
let foo = 'outer';
function bar(func = x => foo) {
let foo = 'inner';
console.log(func()); => outer
}
bar();
上面代码中，函数bar的参数func的默认值是一个匿名函数，返回值为变量foo。这个匿名函数声明时，bar函数的作用域还没有形成，所以匿名函数
里面的foo指向外层作用域的foo，输出outer。

var x = 1;
function foo(x, y = function() { x = 2; }) {
    var x = 3;
    y();
    console.log(x);
}
foo() => 3

上面代码中，函数foo的参数y的默认值是一个匿名函数。函数foo调用时，它的参数x的值为undefined，所以y函数内部的x一开始是undefined，后
来被重新赋值2。但是，函数foo内部重新声明了一个x，值为3，这两个x是不一样的，互相不产生影响，因此最后输出3。
如果将var x = 3的var去除，两个x就是一样的，最后输出的就是2。

8.rest 参数  （形式为 “... 变量名 ” ）
function add(...values) {
    let sum = 0;
for (var val of values) {
    sum += val;
}
    return sum;
}
add(2, 5, 3) => 10

function push(array, ...items) {
items.forEach(function(item) {
array.push(item);
console.log(item);
});
}
var a = [];
push(a, 1, 2, 3)  => a = [1,2,3]

注意， rest 参数之后不能再有其他参数（即只能是最后一个参数），否则会报错。
=>  报错
function f(a, ...b, c) {}
(function(a, ...b) {}).length => 1  不包括 rest 参数。
console.log(1, ...[2, 3, 4], 5) => 1 2 3 4 5


function add(x, y) {
    return x + y;
}
var numbers = [4, 38];
add(...numbers) => 42

function f(x, y, z) {
    => ...
}
var args = [0, 1, 2];
f(...args);

Math.max(...[14, 3, 77])=Math.max(14, 3, 77);

var arr1 = [0, 1, 2];
var arr2 = [3, 4, 5];
arr1.push(...arr2);
new Date(...[2015, 1, 1]);

合并数组
var arr1 = ['a', 'b'];
var arr2 = ['c'];
var arr3 = ['d', 'e'];
[...arr1, ...arr2, ...arr3] => [ 'a', 'b', 'c', 'd', 'e' ]

const [first, ...rest] = [1, 2, 3, 4, 5];
first => 1
rest => [2, 3, 4, 5]

const [first, ...rest] = [];  
first => undefined
rest => []

rest只能放在参数的最后一位

[...'hello'] => [ "h", "e", "l", "l", "o" ]

正确返回string的长度
function length(str) {
    return [...str].length;
}
length('x\uD83D\uDE80y') => 3

8.5  name 属性
函数的name属性，返回该函数的函数名。
const bar = function baz() {};
bar.name => "baz"

8.6  “ 箭头 ” （=>）定义函数。
var f = () => 5;
=>  等同于
var f = function () { return 5 };
var sum = (num1, num2) => num1 + num2;
=>  等同于
var sum = function(num1, num2) {
return num1 + num2;
};

const full = ({ first, last }) => first + ' ' + last;
=>  等同于
function full(person) {
return person.first + ' ' + person.last;
}

const numbers = (...nums) => nums;
numbers(1, 2, 3, 4, 5) => [1,2,3,4,5]
const headAndTail = (head, ...tail) => [head, tail];  
headAndTail(1, 2, 3, 4, 5) => [1,[2,3,4,5]]

8.6.2
箭头函数有几个使用注意点。
1.函数体内的this对象，就是定义时所在的对象，而不是使用时所在的对象。

function insert(value) {
    return {into: function (array) {
        return {after: function (afterValue) {
            array.splice(array.indexOf(afterValue) + 1, 0, value);
            return array;
        }};
    }};
}
等于
let insert = (value) => ({into: (array) => ({after: (afterValue) => {
    array.splice(array.indexOf(afterValue) + 1, 0, value);
    return array;
}})});

8.7.6  尾递归优化的实现
function factorial(n, total = 1) {
    if (n === 1) return total;
    return factorial(n - 1, n * total);
}
factorial(5) => 12

9  对象的扩展
var foo = 'bar';
var baz = {foo};
baz => {foo: "bar"}
var baz = {foo: foo};

var o = {
    method() {
        return "Hello!";
    }
};  方法简写

var ms = {};
function getItem (key) {
    return key in ms ? ms[key] : null;
}
function setItem (key, value) {
    
}
function clear () {
    ms = {};
}

9.2  属性名表达式
let propKey = 'foo';
let obj = {
    [propKey]: true,
    ['a' + 'bc']: 123
};

9.2.1 表达式还可以用于定义方法名。
let obj = {
    ['h'+'ello']() {
         return 'hi';
    }
};
obj.hello() => hi

9.2.2 方法的 name 属性
var person = {
    sayName() {
      console.log(this.name);
    },
    get firstName() {
        return "Nicholas";
    }
};
person.sayName.name => "sayName"
person.firstName.name => "get firstName"

9.4 Object.is()
Object.is('foo', 'foo') => true

9.5 Object.assign()  如果目标对象与源对象有同名属性，或多个源对象有同名属性，则后面的属性会覆盖前面的属性。

var target = { a: 1 };
var source1 = { b: 2 };
Object.assign(target, source1);
target => {a:1, b:2}

Object.assign([1, 2, 3], [4, 5])  => [4, 5, 3]  存在则替换

9.8  __proto__ 属性， Object.setPrototypeOf() ， Object.getPrototypeOf()
let proto = {};
let obj = { x: 10 };
Object.setPrototypeOf(obj, proto);
proto.y = 20;
proto.z = 40;
obj.x => 10
obj.y => 20
obj.z => 40

9.10  Rest 解构赋值
let { x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 }; x => 1 y => 2 z => { a: 3, b: 4 }
let obj = { a: { b: 1 } }; let { ...x } = obj; obj.a.b = 2; x.a.b => 2





