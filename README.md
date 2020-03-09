# MIPS Recursion Project -- Payton Dennis
## @02877343 -- Base: 33

*Note: I understand the directions were listed to use the STACK to store the result which would have been an easier method than I chose. But what made sense to me was to STORE my result using **.text** strings.* 
Besides this change I followed the directions to the best of my ability.

####  Basic High-level Idea of Algorithm:
Peliminary Step: Check tabs/spaces and valid characters. 
1.  Recursively call each character in our string; (which I will call **c**).
2.  Convert c (starting with the rightmost digit; backtrack) to its decimal representation; (which I will call **d**).
3. If c does not need to be multiplied go to step 8. If c does:
4.  Multiply **d** by base (33).
5. Store in **tempAnswer** (string in memory).
6. Check if multiply again by 33
7. If yes go to step 4. If not continue:
8. Add to **tempAnswer** to **finalAnswer**.
9. If done multiplying, check if done with characters: If no go to step 2, if yes continue.
10. Print **finalAnswer**.

Note:  This took incredibly long to do, with a lot of planning, fustration, and time. But I will say it was a learning exprience and taught me how to break a problem down into chunks. It also helped me learn efficient ways to debug a program.
