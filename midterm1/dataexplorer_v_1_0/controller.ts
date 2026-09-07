import express, { Request, Response } from 'express';

const app = express();
const port = 3000;

app.use(express.json());

interface Item {
    id: number;
    name: string;
    description: string;
}

let items: Item[] = [
    { id: 1, name: 'Item 1', description: 'Description 1' },
    { id: 2, name: 'Item 2', description: 'Description 2' }
];

app.get('/items', (req: Request, res: Response) => {
    res.json(items);
});

app.get('/items/:id', (req: Request, res: Response) => {
    const item = items.find(i => i.id === parseInt(req.params.id));
    if (item) {
        res.json(item);
    } else {
        res.status(404).send('Item not found');
    }
});

app.post('/items', (req: Request, res: Response) => {
    const newItem: Item = {
        id: items.length + 1,
        name: req.body.name,
        description: req.body.description
    };
    items.push(newItem);
    res.status(201).json(newItem);
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
