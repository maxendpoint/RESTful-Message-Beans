/***
 * Excerpted from "Prototype and script.aculo.us",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cppsu for more book information.
***/

var Person = Class.create({ 
  initialize: function(first, last, city, country) { 
    this.first = first;
    this.last = last;
    this.city = city;
    this.country = country;
  },

  getFullName: function() {
    return (this.first + ' ' + this.last).strip();
  },

  getDisplayName: function() { 
    var result = this.getFullName();
    if (this.city || this.country) {
      result += ' (';
      if (this.city) {
        result += this.city;
        if (this.country) result += ', ';
      }
      result += (this.country || '');
      result += ')';
    }
    return result;
  }
});


Person.compare = function() {
  var prop = 'first', args = $A(arguments); 
  if (args.length == 3 && typeof args[0] == 'string')
    prop = args.shift();
  var c1 = args[0][prop], c2 = args[1][prop]; 
  return (c1 < c2 ? -1 : (c2 < c1 ? 1 : 0));
};



var people = [
  new Person('Jes "Canllaith"', 'Hall', 'Wellington', 'NZ'),
  new Person('Sebastien', 'Gruhier', 'Carquefou', 'FR'),
  new Person('Clotile', 'Michel'),
  new Person('Stéphane', 'Akkaoui', 'Paris'),
  new Person('Elodie', 'Jaubert', 'Paris')
];


/*

people.pluck('first').sort().uniq().join(', ')
// => 'Clotilde, Elodie, Jes "Canllaith", Sebastien, Stéphane'



people.findAll(function(n) { return n.country; })
  .sort(Person.compare.bind(Person, 'country')).invoke('getDisplayName')
// => [ 'Sebastien Gruhier (Carquefou, FR)',
//      'Jes "Canllaith" Hall (Wellington, NZ)' ]

*/


document.observe('dom:loaded', function() {
  html = '<ul>\n'
    + people.sort(Person.compare).map(function(p) { 
        return '\t<li>' + p.getDisplayName().escapeHTML() + '</li>'; 
      }).join('\n')
    + '</ul>';
  $('result').update(html); 
  $$('#result li:nth-child(2n)').invoke('addClassName', 'alternate'); 
});

