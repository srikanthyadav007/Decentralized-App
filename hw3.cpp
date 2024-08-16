#include <bits/stdc++.h>
#include "matplotlibcpp.h"

namespace plt = matplotlibcpp;
using namespace std;
struct Node
{
    int id;
    double amount=100;
    double trust_worthy_ness=0;
};
void compareVectors(const std::vector<int>& vec1, const std::vector<int>& vec2) {
    std::vector<double> x_points;
    std::vector<double> y_points;
    std::vector<std::string> colors;

    for (size_t i = 0; i < vec1.size(); ++i) {
        x_points.push_back(i);
        if (vec1[i] == vec2[i]) {
            y_points.push_back(0); // Assign y-coordinate as 0 when values are the same
            colors.push_back("green");
        } else {
            y_points.push_back(1); // Assign y-coordinate as 1 when values are different
            colors.push_back("red");
        }
    }

    // Reduce the size of the plot window
    plt::figure_size(800, 300);

    // Plot each segment of the line with the appropriate color
    for (size_t i = 0; i < x_points.size() - 1; ++i) {
        plt::plot({x_points[i], x_points[i + 1]}, {y_points[i], y_points[i + 1]}, colors[i]);
    }
     plt::ylim(-0.5, 1.5);
    plt::show();
}
int main()
{
    Node * user=new Node[100];
    int no_of_users;
    float malicious,p_fraction;
    cout<<"Enter the number of users: ";
    cin>>no_of_users;
    cout<<"Enter the fraction of malicious users: ";
    cin>>malicious;
    cout<<"Enter the p fraction of honest users: ";
    cin>>p_fraction;

    int no_of_malicious= no_of_users* malicious;
    int no_of_p_fraction_honest=no_of_users*(1-malicious)*p_fraction;
    float no_of_rem_honest=no_of_users*(1-malicious)*(1-p_fraction);

    int temp=0;
    while(temp<no_of_p_fraction_honest)
    {
        int u=rand()%no_of_users;
        if(user[u].trust_worthy_ness==0)
        {
            user[u].trust_worthy_ness=0.90;
            temp++;
        }
    }
    temp=0;
    while(temp<no_of_rem_honest)
    {
        int u=rand()%no_of_users;
        if(user[u].trust_worthy_ness==0)
        {
            user[u].trust_worthy_ness=0.70;
            temp++;
        }
    }

    vector<int> news;
    vector<int> result;
    for (int i = 0; i < 100; ++i) {
        int random_number = rand() % 2;  // Generate random number between 0 and 1
        news.push_back(random_number);
    }
    random_device rd;
    mt19937 gen(rd()); 

    std::uniform_int_distribution<int> distribution(0, 100);

    int time=0;
    while(time<100)
    {
        vector<int> guess(100);
        int votes_for_zero=0;
        int votes_for_one=0;
        for(int i=0;i<100;i++)
        {
            float prob = (float)distribution(gen)/100;
            if(prob<=user[i].trust_worthy_ness)
            {
                guess[i]=news[time];
            }
            else
            {
                guess[i]=!news[time];
            }
            user[i].amount--;
            if(guess[i]) votes_for_one++;
            else votes_for_zero++;
        }
        int most_votes;
        int vote_count;
        if(votes_for_one>=votes_for_zero)
        {
            most_votes=1;
            vote_count=votes_for_one;
        }
        else 
        {
            most_votes=0;
            vote_count=votes_for_zero;
        }
        result.push_back(most_votes);
        cout<<"actual news is "<<news[time]<<" most votes for "<<most_votes<<endl;
        for(int i=0;i<100;i++)
        {
            if(guess[i]==most_votes)
            {
                user[i].trust_worthy_ness=(user[i].trust_worthy_ness*(100+time)+1)/(100+time+1);
                user[i].amount+=(no_of_users/vote_count);
            }
            else
            {
                user[i].trust_worthy_ness=(user[i].trust_worthy_ness*(100+time))/(100+time+1);
            }
        }
        time++;
    }

    for(int i=0;i<100;i++)
    {
        cout<<i<<" "<<user[i].trust_worthy_ness<<" "<<user[i].amount<<endl;
    }
    int count=0;
    for(int i=0;i<100;i++)
    {
        if(news[i]==result[i]) count++;
    }
    cout<<"no.of predicted correctly"<<count<<endl;
    compareVectors(news,result);

    cout<<no_of_malicious<<" "<<no_of_p_fraction_honest<<" "<<no_of_rem_honest<<endl;
    
}