from pyswip import Prolog

class QueryExecutor:

    def __init__(self) -> None:
        self.prolog = Prolog()
        self.prolog.consult('prolog_rules.pl')


    def query(self, tokens) -> list:
        query = "sent(X, " + str(tokens) + ", [])."
        outputs = {}
        tree = {}
        for soln in self.prolog.query(query):
            triple = soln['X']
            sub = (' ').join(map(str, triple[0]))
            pred = (' ').join(map(str, triple[1]))
            obj = (' ').join(map(str, triple[2]))
            triple = (sub, pred, obj)

            if sub not in tree:
                tree[sub] = {}
            if pred not in tree[sub]:
                tree[sub][pred] = {}    
            if obj not in tree[sub][pred]:
                tree[sub][pred][obj] = 1
                
            if triple not in outputs:
                outputs[triple] = 1

        self.__pruneTriples(tree)
        outputs = []
        for sub in tree:
            for pred in tree[sub]:
                for obj in tree[sub][pred]:
                    outputs.append((sub, pred, obj))

        return outputs

                

    def __pruneTriples(self, tree):
        self.__prune(tree)

        for sub in tree:
            self.__prune(tree[sub])
            for pred in tree[sub]:
                self.__reversePrune(tree[sub][pred])
        
    def __prune(self, tree):
        key_list = list(tree.keys())
        key_list.sort()
        removeKeys = []
        i=0
        while i < len(key_list):
            j=i+1
            while j<len(key_list):
                if key_list[j].startswith(key_list[i]):
                    removeKeys.append(key_list[i])
                j+=1
            i+=1
        for key in removeKeys:
            if key in tree:
                del tree[key]


    def __reversePrune(self, tree):
        key_list = list(tree.keys())
        key_list.sort()
        removeKeys = []
        i=0
        while i < len(key_list):
            j=i+1
            while j<len(key_list):
                if key_list[j].startswith(key_list[i]):
                    removeKeys.append(key_list[j])
                j+=1
            i+=1

        for key in removeKeys:
            if key in tree:
                del tree[key]