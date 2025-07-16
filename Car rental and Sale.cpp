#include<iostream>
#include<string>
#include<fstream>
#include<iomanip>
char p;int days;                     
void Userchoice(char c);
void Userchoice1(char c);
void pur();
void rent();
void UserInfo();
using namespace std; 
string name,Pr,NC,Md,Fa,cnic,phno;
int Pr1;  //stroring car info which is purchased Pr for Price NC for Car name
string S1="HONDA-CIVIC",S2="TOYOTA-GRANDE",S3="HUYANDI-SONATA",PS1="9Million",PS2="8Million",PS3="10Million";  //sedan Info
string SU1="TOYOTA-FORTUNER",SU2="TOYOTA-REVO",SU3="KIA-SPORTAGE",PSU1="20Million",PSU2="15Million",PSU3="7Million"; //SUV Info
string C1="MERCEDES_BENZ",C2="BMW_M5",C3="AUDI_ETRON",PC1="50Million",PC2="45Million",PC3="40Million"; 
string H1="Honda Civic",H2="Honda Insight",H3="Honda City",HM1="2023  1.8",HM2="2020  1.6",HM3="2021  1.6",HF1="13.6 km",HF2="15.2 km",HF3="12 km";
int HR1=50000,HR2=45000,HR3=43000; 
string T1="Corolla Altis ",T2="Corolla Grande",T3="Corolla Gli",TM1="2023    Auto",TM2="2022    Auto",TM3="2021    Manual",TF1="13 km",TF2="14 km",TF3="12.7 km";
int TT1=50000,TT2=45000,TT3=43000; 
string SUZ1="Suzuki Alto",SUZ2="Suzuki Mehran",SUZ3="Suzuki Cultus",SM1="2023    Auto",SM2="2022    Auto",SM3="2021    Manual",SF1="15.6 km",SF2="14 km",SF3="14 km";
int SUZU1=50000,SUZU2=45000,SUZU3=43000;    
  //comfort Info                                                                                                                                                             
int main()                                                                                                                                                                   
{ fstream cat;                                                                                            
	int choice,ch2;char c;
	cout<<"-----Welcome To ABC Car Dealership-----  "<<"\n\n";
	cout<<"---------------------------------"<<endl;
	cout<<"\tWhat you want"<<endl;
	cout<<"---------------------------------"<<endl;
a:	cout<<"1)\t"<<"BUY A CAR "<<" "<<endl;
	cout<<"2)\t"<<"RENT A CAR"<<" " <<endl;
	cout<<"---------------------------------"<<endl;
	cout<<"Enter your choice between 1-2"<<endl;
	cout<<"---------------------------------"<<endl;
	cin>>choice;
	system("CLS");
	if(choice==1)
	{  cout<<"---------------------------------"<<endl;
	cout<<"Please Select Category :"<<endl;
	cout<<"---------------------------------"<<endl;
		cat.open("cars.txt",ios::in);
		string car;
		while(cat>>car)
		{	cout<<"---------------------------------"<<endl;
			cout<<car<<endl;
		}
		cout<<"---------------------------------"<<endl;
		cat.close();
		cin>>c;
		system("CLS");
	Userchoice(c);
	if(p=='a'||p=='b'||p=='c')
	{
	UserInfo();
	system("CLS");
	pur();
}
	}
	else if(choice==2)
	{
		
	  cout<<"Please Select Category :"<<endl;
		cat.open("cars.txt",ios::in);
		string car;
		while(cat>>car)
		{	cout<<"---------------------------------"<<endl;
			cout<<car<<endl;
		}
		cout<<"---------------------------------"<<endl;
		cat.close();
		cin>>c;
		system("CLS");
		Userchoice1(c);
	if(p=='a'||p=='b'||p=='c')
	{
	UserInfo();
	system("CLS");
	rent();
}
	else
	{
		cout<<"Wrong Selction"<<endl;
		cout<<"You Want to Select Again (press 1)"<<endl;
		cin>>ch2;
		if(ch2==1)
		goto a;
		else
		cout<<"Thankyou for Visiting ";
	}
}
}
void Userchoice(char c)
{ 
	switch(c)
			{
				case '1':
					{
					    cout<<"In Sedan We have Following Collection for Buying:\n";
					    cout<<"(a)"<<S1<<"----------------------------------"<<"Price="<<PS1<<endl;
						cout<<"(b)"<<S2<<"--------------------------------"<<"Price="<<PS2<<endl;
						cout<<"(c)"<<S3<<"-------------------------------"<<"Price="<<PS3<<endl;
				        cout<<"For Buying Click the Characters written before Name Of Car: "<<endl;
					cin>>p;
				switch(p)
				{
					case 'a':
						Pr=PS1;NC=S1;break;
						case 'b':
							Pr=PS2;NC=S2;break;
							case 'c':
								Pr=PS3;NC=S3;break;
				}
					
					}break;
					case '2':
						{
							cout<<"In SUV We have Following Collection for Buying:\n";
								cout<<"(a)"<<SU1<<"----------------------------"<<"Price="<<PSU1<<endl;
						        cout<<"(b)"<<SU2<<"--------------------------------"<<"Price="<<PSU2<<endl;
							    cout<<"(c)"<<SU3<<"-------------------------------"<<"Price="<<PSU3<<endl;
                                 cout<<"For Buying Click the Characters written before Name Of Car: "<<endl;
					 cin>>p;
					 	switch(p)
				{
					case 'a':
						Pr=PSU1;NC=SU1;break;
						case 'b':
							Pr=PSU2;NC=SU2;break;
							case 'c':
								Pr=PSU3;NC=SU3;break;
				}	} break;
						case '3':
							{
							cout<<"In COMFORT We have Following Collection for Buying:\n";
								cout<<"(a)"<<C1<<"----------------------------------"<<"Price="<<PC1<<endl;
						        cout<<"(b)"<<C2<<"-----------------------------------------"<<"Price="<<PC2<<endl;
							    cout<<"(c)"<<C3<<"-------------------------------------"<<"Price="<<PC3<<endl;
							    cout<<"For Buying Click the Characters written before Name Of Car: "<<endl;
						cin>>p;
							switch(p)
				{
					case 'a':
						Pr=PC1;NC=C1;break;
						case 'b':
							Pr=PC2;NC=C2;break;
							case 'c':
								Pr=PC3;NC=C3;break;
				}	}break;
							default:
								cout<<"Wrong Selection";
			}

	
}
void Userchoice1(char c)
{ 

	switch(c)
			{
				
				case '1':
					{
					    	cout<<"In Sedan We have Following Collection for Rent:\n";
					    	cout<<"---------------------------------------------"<<endl;
					    	cout<<"   Cars"<<"  \t\t Model   "<<"\tRent/Day   "<<"\tFuel Avg"<<endl;
					    	cout<<"---------------------------------------------------------------"<<endl;
							cout<<"a)"<<H1<<"\t\t"<<HM1<<"\t"<<HR1<<"\t"<<"\t"<<HF1<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"b)"<<H2<<"\t\t"<<HM2<<"\t"<<HR2<<"\t"<<"\t"<<HF2<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"c)"<<H3<<"\t\t"<<HM3<<"\t"<<HR3<<"\t"<<"\t"<<HF3<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
				        cout<<"For Buying Click the Characters written before Name Of Car: "<<endl;
				        cout<<"---------------------------------------------------------------"<<endl;
					cin>>p;
					cout<<"---------------------------------------------------------------"<<endl;
					 cout<<"Enter number of days you want to take car on rent"<<endl;
						cout<<"---------------------------------------------------------------"<<endl;
						cin>>days;
						system("CLS");
				switch(p)
				{
					case 'a':
						Pr1=HR1*days,NC=H1,Md=HM1,Fa=HF1;break;
						case 'b':
							Pr1=HR2*days,NC=H2,Md=HM2,Fa=HF2;break;
							case 'c':
								Pr1=HR3*days,NC=H3,Md=HM3,Fa=HF3;break;
				}
					
					}break;
					case '2':
						{	
							cout<<"In SUV We have Following Collection for Buying:\n";
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"   Cars"<<" \t\t  Model "<<"\t       Rent/Day   "<<"\tFuel Avg"<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"a)"<<T1<<"\t"<<TM1<<"\t\t"<<TT1<<"\t"<<"\t"<<TF1<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"b)"<<T2<<"\t"<<TM2<<"\t\t"<<TT2<<"\t"<<"\t"<<TF2<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"c)"<<T3<<"\t\t"<<TM3<<"\t\t"<<TT3<<"\t"<<"\t"<<TF3<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
                            cout<<"For Buying Click the Characters written before Name Of Car: "<<endl;
                            cout<<"---------------------------------------------------------------"<<endl;
							 cin>>p;
					 		cout<<"---------------------------------------------------------------"<<endl;
					 		cout<<"Enter number of days you want to take car on rent"<<endl;
					 		cout<<"---------------------------------------------------------------"<<endl;
							cin>>days;
							system("CLS");
					 	switch(p)
				{
					case 'a':
						Pr1=TT1*days,NC=T1,Md=TM1,Fa=TF1;break;
						case 'b':
							Pr1=TT2*days,NC=T2,Md=TM2,Fa=TF2;break;
							case 'c':
							Pr1=TT3*days,NC=T3,Md=TM3,Fa=TF3;break;
				}	} break;
						case '3':
							{
							cout<<"In COMFORT We have Following Collection for Buying:\n";
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"   Cars"<<" \t\t   Model "<<"\t\tRent/Day   "<<"\tFuel Avg"<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"a)"<<SUZ1<<"\t\t"<<SM1<<"\t\t"<<SUZU1<<"\t"<<"\t"<<SF1<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"b)"<<SUZ2<<"\t\t"<<SM2<<"\t\t"<<SUZU2<<"\t"<<"\t"<<SF2<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"c)"<<SUZ3<<"\t\t"<<SM3<<"\t\t"<<SUZU3<<"\t"<<"\t"<<SF3<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cout<<"For Buying Click the Characters written before Name Of Car: "<<endl;
							cout<<"---------------------------------------------------------------"<<endl;
							cin>>p;
							cout<<"---------------------------------------------------"<<endl;
							cout<<"Enter number of days you want to take car on rent"<<endl;
							cout<<"-----------------------------------------------------"<<endl;
							cin>>days;
							system("CLS");
							switch(p)
				{
					case 'a':
						Pr1=SUZU1*days,NC=SUZ1,Md=SM1,Fa=SF1;break;
						case 'b':
							Pr1=SUZU2*days,NC=SUZ2,Md=SM2,Fa=SF2;break;
							case 'c':
								Pr1=SUZU3*days,NC=SUZ3,Md=SM3,Fa=SF3;break;
				}	}break;
							default:
								cout<<"---------------------"<<endl;
								cout<<"Wrong Selection";
								cout<<"---------------------"<<endl;
			}

	
}
void pur()
{        cout<<"\n\t\t                       ABC Dealership - Customer Invoice                  "<<endl;
     cout<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
     cout<<"\t\t	| Invoice No. :"<<"------------------|"<<setw(10)<<"#Cnb81353"<<" |"<<endl;
     cout<<"\t\t	| Customer Name:"<<"-----------------|"<<setw(10)<<name<<" |"<<endl;
     cout<<"\t\t	| Customer CNIC:"<<"-----------------|"<<cnic<<" |"<<endl;
     cout<<"\t\t	| Customer Phone No:"<<"-------------|"<<phno<<" |"<<endl;
     cout<<"\t\t	| Car Model :"<<"--------------------|"<<setw(10)<<NC<<" |"<<endl;
     cout<<"\t\t	| Car No. :"<<"----------------------|"<<setw(10)<<"3818"<<" |"<<endl;
     cout<<"\t\t	| Price :"<<"------------------------|"<<setw(10)<<Pr<<" |"<<endl;
     cout<<"\t\t	| Advanced :"<<"---------------------|"<<setw(10)<<"0"<<" |"<<endl;
     cout<<"\t\t	 ________________________________________________________"<<endl;
     cout<<"\n";
     cout<< "\t\t	 ________________________________________________________"<<endl;
     cout<< "\t\t	 # This is a computer generated invoce and it does not"<<endl;
     cout<<"\t\t	 require an authorised signture #"<<endl;
     cout<<" "<<endl;
     cout<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
     cout<<"\t\t	You are advised to pay up the amount before due date."<<endl;
     cout<<"\t\t	Otherwise penelty fee will be applied"<<endl;
     cout<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
  fstream invoice;
    invoice.open("Invoice.txt",ios::out);
    invoice<<"\n\t\t                       ABC Dealership - Customer Invoice                  "<<endl;
    invoice<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
    invoice<<"\t\t	| Invoice No. :"<<"------------------|"<<setw(10)<<"#Cnb81353"<<" |"<<endl;
    invoice<<"\t\t	| Customer Name:"<<"-----------------|"<<setw(10)<<name<<" |"<<endl;
    invoice<<"\t\t	| Customer CNIC:"<<"-----------------|"<<cnic<<" |"<<endl;
    invoice<<"\t\t	| Customer Phone No:"<<"-------------|"<<phno<<" |"<<endl;
    invoice<<"\t\t	| Car Model :"<<"--------------------|"<<setw(10)<<NC<<" |"<<endl;
    invoice<<"\t\t	| Car No. :"<<"----------------------|"<<setw(10)<<"3818"<<" |"<<endl;
    invoice<<"\t\t	| Price :"<<"------------------------|"<<setw(10)<<Pr<<" |"<<endl;
    invoice<<"\t\t	| Advanced :"<<"---------------------|"<<setw(10)<<"0"<<" |"<<endl;
    invoice<<"\t\t	 ________________________________________________________"<<endl;
    invoice<<"\n";
    invoice<< "\t\t	 ________________________________________________________"<<endl;
    invoice<< "\t\t	 # This is a computer generated invoce and it does not"<<endl;
    invoice<<"\t\t	 require an authorised signture #"<<endl;
    invoice<<" "<<endl;
    invoice<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
    invoice<<"\t\t	You are advised to pay up the amount before due date."<<endl;
    invoice<<"\t\t	Otherwise penelty fee will be applied"<<endl;
    invoice<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
    invoice.close();
	cout<<"Invoice is Generated Download It Thankyou For Trusting Our Dealership hope to see you again"<<endl;}
	
	void rent()
{        cout<<"\n\t\t                       ABC Dealership - Customer Invoice                  "<<endl;
     cout<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
     cout<<"\t\t	| Invoice No. :"<<"------------------|"<<setw(10)<<"#Cnb81353"<<" |"<<endl;
     cout<<"\t\t	| Customer Name:"<<"-----------------|"<<setw(10)<<name<<" |"<<endl;
     cout<<"\t\t	| Customer CNIC:"<<"-----------------|"<<cnic<<" |"<<endl;
     cout<<"\t\t	| Customer Phone No:"<<"-------------|"<<phno<<" |"<<endl;
     cout<<"\t\t	| Car Model :"<<"--------------------|"<<setw(10)<<NC<<" |"<<endl;
     cout<<"\t\t	| Car No. :"<<"----------------------|"<<setw(10)<<"3818"<<" |"<<endl;
     cout<<"\t\t	| Price :"<<"------------------------|"<<setw(10)<<Pr1<<" |"<<endl;
     cout<<"\t\t	| Number of days car rented:"<<"-----|"<<setw(10)<<days<<" |"<<endl;
     cout<<"\t\t	| Advanced :"<<"---------------------|"<<setw(10)<<"0"<<" |"<<endl;
     cout<<"\t\t	 ________________________________________________________"<<endl;
     cout<<"\n";
     cout<< "\t\t	 ________________________________________________________"<<endl;
     cout<< "\t\t	 # This is a computer generated invoce and it does not"<<endl;
     cout<<"\t\t	 require an authorised signture #"<<endl;
     cout<<" "<<endl;
     cout<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
     cout<<"\t\t	You are advised to pay up the amount before due date."<<endl;
     cout<<"\t\t	Otherwise penelty fee will be applied"<<endl;
     cout<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
  fstream invoice;
    invoice.open("Invoice.txt",ios::out);
    invoice<<"\n\t\t                       ABC Dealership - Customer Invoice                  "<<endl;
    invoice<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
    invoice<<"\t\t	| Invoice No. :"<<"------------------|"<<setw(10)<<"#Cnb81353"<<" |"<<endl;
    invoice<<"\t\t	| Customer Name:"<<"-----------------|"<<setw(10)<<name<<" |"<<endl;
    invoice<<"\t\t	| Customer CNIC:"<<"-----------------|"<<cnic<<" |"<<endl;
    invoice<<"\t\t	| Customer Phone No:"<<"-------------|"<<phno<<" |"<<endl;
    invoice<<"\t\t	| Car Model :"<<"--------------------|"<<setw(10)<<NC<<" |"<<endl;
    invoice<<"\t\t	| Car No. :"<<"----------------------|"<<setw(10)<<"3818"<<" |"<<endl;
    invoice<<"\t\t	| Price :"<<"------------------------|"<<setw(10)<<Pr1<<" |"<<endl;
    invoice<<"\t\t	| Advanced :"<<"---------------------|"<<setw(10)<<"0"<<" |"<<endl;
    invoice<<"\t\t	 ________________________________________________________"<<endl;
    invoice<<"\n";
    invoice<< "\t\t	 ________________________________________________________"<<endl;
    invoice<< "\t\t	 # This is a computer generated invoce and it does not"<<endl;
    invoice<<"\t\t	 require an authorised signture #"<<endl;
    invoice<<" "<<endl;
    invoice<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
    invoice<<"\t\t	You are advised to pay up the amount before due date."<<endl;
    invoice<<"\t\t	Otherwise penelty fee will be applied"<<endl;
    invoice<<"\t\t	///////////////////////////////////////////////////////////"<<endl;
    invoice.close();
	cout<<"Invoice is Generated Download It Thankyou For Trusting Our Dealership hope to see you again"<<endl;}
void UserInfo()
{
	cout<<"---------------------------------"<<endl;
	cout<<"Enter Your Full Name: "<<endl;
	cout<<"---------------------------------"<<endl;
	getline(cin>>ws,name);
	cout<<"---------------------------------"<<endl;
	cout<<"Enter Your Valid CNIC:"<<endl;
	cout<<"---------------------------------"<<endl;
	getline(cin>>ws,cnic);
	cout<<"---------------------------------"<<endl;
	cout<<"Enter Your Phone Number: "<<endl; 
	cout<<"---------------------------------"<<endl;
	getline(cin>>ws,phno);
}
