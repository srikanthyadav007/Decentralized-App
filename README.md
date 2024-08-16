# Decentralized-App
A Decentralized App (DApp) is an application running on a permissionless blockchain. A DApp is usually implemented as a smart contract. A smart contract is essentially a program whose code is on the blockchain. The code is initially put on the blockchain in a transaction. The smart contract can have many functions. Different functions can be invoked by other transactions later on, provided the person invoking the function(s) has the permissions to do so as specified by the smart contract. When different functions are executed, the state of the smart contract are modified.


The simulation code is in hw3.cpp

To compile the file command is 

g++ hw3.cpp -o hw3 -I/usr/include/python3.8 -lpython3.8

//here the python3.8 is the version of python in system. We need to change based on the version in your system.

after compiling the file , we will get object file hw3.


Run the command
./hw3

Enter the number of users: 100
Enter the fraction of malicious users: 0.4   //it should be float number
Enter the p fraction of honest users: 0.2    //it should be float number.


After giving the inputs, we will get 100 news article types and the predicted type.

At last it will print the trustworthiness and amount left at each user after 100 articles.

And at last we will get no.of correctly predicted articles out of 100 news articels.
