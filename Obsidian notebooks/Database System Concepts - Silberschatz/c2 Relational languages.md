# c2 Relational languages
Created: 2021-12-14 13:41
Tags: #databases #data-science 
***

**Table of Contents**

- [[#Database Schema|Database Schema]]
- [[#Keys ^database-keys-definitions|Keys ^database-keys-definitions]]
- [[#Schema diagrams ^database-schema-diagrams-basic-terms|Schema diagrams ^database-schema-diagrams-basic-terms]]
- [[#Relational query languages ^database-query-langauge-basic-taxonomy|Relational query languages ^database-query-langauge-basic-taxonomy]]
- [[#Relational algebra ^database-relational-algebra-basic-notation|Relational algebra ^database-relational-algebra-basic-notation]]
	- [[#Basic operations|Basic operations]]
	- [[#Set operations|Set operations]]

# Relational model 
#relational-model 
- data model = conceptual tools for describing data, relationships between data, semantics of data, and consistency constraints
- relational model = tables that represent data and relations between data 
	- logical and view levels 
	- hides low-level details of data storag
	- queries retrieve and update data

## Structure of relational databases ^database-structure-basic-terms
- relational database = collection of **tables**
	- each table has unique name 
	- table aka **relation** because values within a row are related to each other
	- row within a table aka **tuple**
	- column aka **attribute**
		- **arity** = number of attributes
	- **relation instance** = specific set of rows 
- relation is a **set** of tuples => order of tuples in relation are irrelevant 
	- i.e. whether sorted or not, relations between data are the same 
- **domain** of attribute = set of permitted values for given column
	- domains of all attributes must be **atomic** = indivisible
	- e.g. phone_number would not be atomic if an element of the domain is a set of phone numbers, rather than a single phone number
	- atomic or not is relative: e.g. single phone number can be split into area code + etc., but could also treat each phone number as a single indivisible unit 
- structured database has practical advantages, but not all applications

## Database Schema
- database schema = logical design 
- database instance = snapshot of data in database at a given time
- relation schema ~` type` of a variable vs. relation ~ instance of variable
	-	varaible value may change (relation insance), but not type (relation schema)

## Keys ^database-keys-definitions
- attribute values must uniquely identify a tuple => no two tuples in a relation can be entirely identical
	- mathematical definition of set = no duplicate elements -> not practical 
	- multisets = sets that can contain duplicates -> practical
- key = property of a relation (not of individual tuples)
	- no two tuples can have overlapping values for key attributes
- superkey = set of one or more attributes that collectively uniquely identify tuples in a relation
	- i.e. sufficient critieria for identification
	- there may be multiple unique attributes, so superkey may contain multiple attributes 
	- any superset of superkey also contains the unique attributes, so any superset will be a superkey
- candidate keys = minimal superkeys 
	- i.e. no subset is a superkey 
	- ~ basis for a vector space 
- primary key = candidate key chosen by database designer as principle means of identifying tuples in relation
	- aka primary key constraints => constrain how data is modelled 
	- come first in a schema, e.g. `classroom (building, room_number, capacity)` where building and room number are keys, since multiple rooms/building pairs can have the same capacity
	- attributes values never/rarely change
- **foreign key constraint** from attribute(s) $A$ of relation $r_1$ to the primary key $B$ of relation $r_2$: the value of $A$ for each tuple in $r_1$ must match $B$ for some tuple in $r_2$
	- $A$ = foreign key from $r_1$ that references $r_2$ 
	- $r_1$ = 'referencing relation' of the foreign key constraint
	- $r_2$ = 'referenced relation'
- referential-integrity constraint = similar to foreign key constraint, but referenced attribute(s) ($B$ above) need not be primary keys of referenced relation ($r_2$ above)
	- values of specified attributes of any tuple in $r_1$ can be found in specified attributes in any tuple of $r_2$
	- not usually supported

## Schema diagrams ^database-schema-diagrams-basic-terms
- primary key = underlined
- foreign key constraints = arrows from foreign-key attributes of $r_1$ to primary key of $r_2$
	- two-headed arrow = referential integrity constraint that is not a foreign key constraint (i.e. $B$ not primary key of $r_2$)

## Relational query languages ^database-query-langauge-basic-taxonomy
- query language = language that requests information from database
	- higher than standard programming language
	- imperative, functional, or declarative
- imperative QL = give sequence of database operations 
	- state variables that are updated during computation
- functional QL = evaluation of functions on data or on other functions, e.g. $f( g( h (...)))$
	- side-effect free
	- do not update program state
- declarative QL = describes desired information without specific instructions -> system figures out necessary steps
	- e.g. user gives mathematical logic 
- most practical languages include elements of all three

## Relational algebra ^database-relational-algebra-basic-notation
- operations that take one or two relations as input to produce new relation
- unary = operate on one relation, e.g. select, rename
- binary = operate on pairs of relations, e.g. union, difference

### Basic operations
- assignment $\leftarrow$ = assign output of relational algebra expression to temporary variable
- rename $\rho_x (E)$ = returns result of expression $E$ and names it as $x$ 
	- 
	- rename specific attributes $A_i$: $\rho_{x(A_1, \dots)} (E)$
- Select $\sigma_x$ = select tuples satisfying a predicate
	- connectives 
		- $\textlnot$ = not 
		- $\vee$ = or 
		- $\wedge$ = and 
- Project $\prod_x$ = return argument relation with certain attributes left out 
	- since relation is a set, removes any duplicate rows 
- Cartesian product $r_1 \times r_2$ = concatenates tuples $t_1$ and $t_2$ into a single tuple:
	- $(t_{11}, t_{12}, \dots t_{21}, t_{22}, \dots)$
	- vs. in set theory, produces paris $(t_1 , t_2)$
	- for attribute names present in both relations, append relation name to attribute name, e.g. `relation.attribute`
		- relations must ahve different names 
		- if $n_i$ elements in $r_i$, then $r_3 = r_1 \times r_2$ has $n_1 n_2$ elements.
- join $r \bowtie_\theta s$ = combines selection and Cartesian product 
	- consider relations $r(R)$ and $s(S)$. let $\theta$ be predicate on attributes in $R \cup S$. Then, `join` is defined as
$$ r \bowtie_\theta s = \sigma_\theta ( r \times s ) $$
	- i.e. filters full Cartesian product of $r$ and $s$

### Set operations
$$\prod_{course\_id} ( \sigma_{semester = 'Fall' \ \wedge \ year=2017}(section))$$
All courses taught in Fall 2017,  remove `course_id`

- intersection and union = input and output relations must have same 
	- [[#^database-structure-basic-terms|**arity**]] (number of attributes)
	- attribute types 
- **compatible** relations = relations with same arity and attribute types 
- set difference $r - s$ = tuples in $r$ but not in $s$
