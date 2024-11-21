#include <iostream>
#include <string>
using namespace std;

struct Node { // d���m yap�s�n� olu�turan struct tan�mlamas�
    string name; // d���m ad�
    int id; // d���m numaras�

    Node* left; // sol �ocuk d���m pointer
    Node* right; // sa� �ocuk d���m pointer

    Node(string n, int i) : name(n), id(i), left(NULL), right(NULL) {} // d���m yap�s�n�n yap�c� fonksiyonu
	
    //* will check it --- Node(string n, int i) : name(n), id(i), left(NULL), right(NULL) {} // d���m yap�s�n�n yap�c� fonksiyonu
};

class BST {
private:
    Node* root; // a�ac�n k�k d���m�

    Node* insert(Node* node, string name, int id) { // a�aca yeni d���m ekleyen yard�mc� fonksiyon
        if (node == NULL) // e�er d���m bo�sa
            return new Node(name, id); // yeni d���m olu�turmam�z laz�m

        if (id < node->id) { // e�er id daha k���kse
            node->left = insert(node->left, name, id); // sol alt a�aca ekle name id
        } else { // de�ilse
            node->right = insert(node->right, name, id); // sa� alt a�aca ekle name id
        }
        return node; // g�ncellenmi� d���m� d�nd�r
    }

    Node* findMin(Node* node) { // a�ac�n min d���m�n� bulan
        while (node->left != NULL) { // sol �ocuk var olduk�a
            node = node->left; // sol alt d���me git
        }
        return node; // en sol d���m� d�nd�r
    }

    Node* findMax(Node* node) { // a�ac�n max d���m�n� bulan
        while (node->right != NULL) { // sa� �ocuk var olduk�a
            node = node->right; // sa� alt d���me git
        }
        return node; // en sa� d���m� d�nd�r
    }

public:
    BST() : root(NULL) {} // yap�c� fonksiyon ile k�k d���m� ba�lat

    void insert(string name, int id) { // public insert fonksiyonu
        root = insert(root, name, id); // yard�mc� fonksiyonu �a��r
    }

    Node* findMin() { // public findMin fonksiyonu
        if (root == NULL) // a�a� bo�sa
            return NULL;
        return findMin(root); // findMin yard�mc� fonksiyonunu k�k d���mle �a��r
    }

    Node* findMax() { // public findMax fonksiyonu
        if (root == NULL) // a�a� bo�sa
            return NULL;
			
        return findMax(root); // findMax yard�mc� fonksiyonunu k�k d���mle �a��r
    }

    void printNode(Node* node) { // d���m� yazd�ran fonksiyon
        if (node != NULL)
            cout << "name: " << node->name << ", id: " << node->id << endl;
    }
};

int main() {
    BST bst; // bst nesnesi olu�turduk
    bst.insert("Ahmet", 4231);
    bst.insert("Ayse", 2243);
    bst.insert("Sam", 1890);
	bst.insert("Dora", 1890); //ID probleminin testi **
    bst.insert("Can", 8237);
    bst.insert("Canan", 3421);
    bst.insert("Hasan", 6781); // a�aca d���mleri ekledik
	cout << endl;

    cout << endl;
    cout << "findMin() ve findMax() uygulamas�" << endl;

    Node* minNode = bst.findMin();
    Node* maxNode = bst.findMax();

    cout << "findMin()= ";
    bst.printNode(minNode);
    cout << "findMax()= ";
    bst.printNode(maxNode);

    return 0;
}

