class FileParser:
    def __init__(self):
        self.sentences = []
        self.labels = []
        self.outputs = dict()
        pass

    def loadFile(self, filepath):
        f = open(filepath)
        s = f.readline()
        sub = []
        pred = []
        obj = []
        while s:
            if s[0]<'0' or s[0]>'9': #text sentence
                self.sentences.append(s.strip())
                self.labels.append({})
            else:
                s = s.strip().split('\t')
                index = int(s[0])
                output = int(s[-1])
                if output==1:
                      
                    i=1
                    key = []
                    while i<len(s)-1:
                        key.append(s[i][1:-1])
                        i+=1

                    if len(key)==3:
                        if key[0] not in sub:
                            sub.append(key[0])
                        if key[1] not in pred:
                            pred.append(key[1])
                        if key[2] not in obj:
                            obj.append(key[2])
                    
                    
                    self.labels[index][tuple(key)] = output
                    
            s = f.readline()
        f.close()
