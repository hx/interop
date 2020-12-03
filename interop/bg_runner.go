package interop

type bgRunner struct {
	runner interface {
		Run() error
	}
	blocker chan error
}

// Start calls the receiver's Run command in a new goroutine. Wait will block and return its error when it finishes.
func (b *bgRunner) Start() {
	if b.runner == nil {
		panic("nothing to start")
	}
	b.blocker = make(chan error, 1) // Buffer to prevent goroutine from leaking if Wait isn't called
	go func() {
		b.blocker <- b.runner.Run()
		close(b.blocker)
	}()
}

// Wait for the process to finish running in the background, returning its error. Panics unless Start has been called.
func (b *bgRunner) Wait() error {
	return <-b.blocker
}
