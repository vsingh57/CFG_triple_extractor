from file_parser import FileParser

class Evaluator:
    def __init__(self) -> None:
        pass

    def __precision(self) -> float:
        return self.ValidGen / self.TotalGen
    
    def __recall(self) -> float:
        return self.ValidGen / self.TotalRec
    
    def __F1(self) -> float:
        prec = self.__precision()
        rec = self.__recall()
        return 2 * prec * rec / (prec + rec)
        
    def evaluate(self, fp:FileParser):
        self.ValidGen = 0
        self.TotalGen = 0
        self.TotalRec = 0    

        for i in range(len(fp.sentences)):
            for triple in fp.outputs[i]:
                if triple in fp.labels[i]:
                    self.ValidGen += 1
            self.TotalGen += 1
            self.TotalRec += len(fp.labels[i])

        print(self.ValidGen, self.TotalGen, self.TotalRec)

        print('\nPRECISION: ' + str(self.__precision()) + '\nRECALL: ' + str(self.__recall()) 
              + '\nF1 SCORE: ' + str(self.__F1()) + '\n')

        