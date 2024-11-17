#include <iostream>
#include <string>
using namespace std;

struct Node { // düðüm yapýsýný oluþturan struct tanýmlamasý
    string name; // düðüm adý
    int id; // düðüm numarasý

    Node* left; // sol çocuk düðüm pointer
    Node* right; // sað çocuk düðüm pointer

    Node(string n, int i) : name(n), id(i), left(NULL), right(NULL) {} // düðüm yapýsýnýn yapýcý fonksiyonu
};

class BST {
private:
    Node* root; // aðacýn kök düðümü

    Node* insert(Node* node, string name, int id) { // aðaca yeni düðüm ekleyen yardýmcý fonksiyon
        if (node == NULL) // eðer düðüm boþsa
            return new Node(name, id); // yeni düðüm oluþturmamýz lazým

        if (id < node->id) { // eðer id daha küçükse
            node->left = insert(node->left, name, id); // sol alt aðaca ekle name id
        } else { // deðilse
            node->right = insert(node->right, name, id); // sað alt aðaca ekle name id
        }
        return node; // güncellenmiþ düðümü döndür
    }

    Node* findMin(Node* node) { // aðacýn min düðümünü bulan
        while (node->left != NULL) { // sol çocuk var oldukça
            node = node->left; // sol alt düðüme git
        }
        return node; // en sol düðümü döndür
    }

    Node* findMax(Node* node) { // aðacýn max düðümünü bulan
        while (node->right != NULL) { // sað çocuk var oldukça
            node = node->right; // sað alt düðüme git
        }
        return node; // en sað düðümü döndür
    }

public:
    BST() : root(NULL) {} // yapýcý fonksiyon ile kök düðümü baþlat

    void insert(string name, int id) { // public insert fonksiyonu
        root = insert(root, name, id); // yardýmcý fonksiyonu çaðýr
    }

    Node* findMin() { // public findMin fonksiyonu
        if (root == NULL) // aðaç boþsa
            return NULL;
        return findMin(root); // findMin yardýmcý fonksiyonunu kök düðümle çaðýr
    }

    Node* findMax() { // public findMax fonksiyonu
        if (root == NULL) // aðaç boþsa
            return NULL;
        return findMax(root); // findMax yardýmcý fonksiyonunu kök düðümle çaðýr
    }

    void printNode(Node* node) { // düðümü yazdýran fonksiyon
        if (node != NULL)
            cout << "name: " << node->name << ", id: " << node->id << endl;
    }
};

int main() {
    BST bst; // bst nesnesi oluþturduk
    bst.insert("Ahmet", 4231);
    bst.insert("Ayse", 2243);
    bst.insert("John", 1502);
    bst.insert("Sam", 1890);
    bst.insert("Can", 8237);
    bst.insert("Canan", 3421);
    bst.insert("Hasan", 6781); // aðaca düðümleri ekledik

    cout << endl;
    cout << "findMin() ve findMax() uygulamasý" << endl;

    Node* minNode = bst.findMin();
    Node* maxNode = bst.findMax();

    cout << "findMin()= ";
    bst.printNode(minNode);
    cout << "findMax()= ";
    bst.printNode(maxNode);

    return 0;
}

