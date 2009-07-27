/***
 * Excerpted from "Prototype and script.aculo.us",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cppsu for more book information.
***/
function Person(lastName, firstName) { 
  this.lastName = lastName;
  this.firstName = firstName;
}

Person.prototype = { 
  getFullName: function() {
    return this.firstName + ' ' + this.lastName;
  }
}

var sam = new Person('Stephenson', 'Sam'); 
var thomas = new Person('Fuchs', 'Thomas');

sam.getFullName() 
// -> 'Sam Stephenson'
thomas.getFullName()
// -> 'Thomas Fuchs'
